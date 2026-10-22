import { CurrencyPipe, DatePipe, KeyValuePipe } from '@angular/common';
import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import {
  AccionPoliza,
  DetallePolizaRamo,
  DocumentoPoliza,
  Poliza,
  Recibo,
} from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/** Textos literales del diálogo de acciones de póliza y de la ficha de póliza en PGM (área B). */
export const TEXTOS_POLIZA = {
  acciones: 'Acciones',
  ir: 'IR',
  documentacion: 'Documentación de emisión',
  consultaDescarga: 'CONSULTA DESCARGA DOCUMENTOS',
  resumen: 'Resumen Póliza',
  recibos: 'Recibos de la póliza',
  garantias: 'Garantías',
  beneficiarios: 'Beneficiarios',
  sinDocumentos: 'No hay documentación disponible para esta póliza',
  cerrar: 'CERRAR',
};
export type TipoDetallePoliza =
  'AUTOS' | 'SALUD' | 'VIDA' | 'HOGAR' | 'CONSUMO_PROTEGIDO' | 'HIPOTECA_SEGURA' | 'GENERICA';
export const PESTANAS_AUTOS_SECCIONES = [
  'Inf. general',
  'Riesgo',
  'Figuras tomador',
  'Observaciones',
] as const;
export const PESTANAS_HOGAR_SECCIONES = [
  'Riesgo',
  'Figuras',
  'Vivienda',
  'Tomador/Asegurado',
  'Observaciones',
] as const;
export const PESTANAS_AUTOS_INFO_GENERAL = [
  'Inf. general',
  'Figuras',
  'Coberturas',
  'Bonus malus',
  'Autorizaciones',
  'Pago',
  'Recibos',
  'Prestaciones',
] as const;
export const PESTANAS_AUTOS_RIESGO = [
  'Características',
  'Carrozados específicos',
  'Equipamientos',
  'Estado del vehículo',
] as const;
export const PESTANAS_AUTOS_FIGURAS_TOMADOR = [
  'Datos Generales',
  'Domicilios',
  'Formas de contacto',
] as const;
export const PESTANAS_AUTOS_OBSERVACIONES = [
  'Cláusulas generales',
  'Observaciones nivel póliza',
] as const;
export const PESTANAS_HOGAR_RIESGO = [
  'Objeto asegurado',
  'Protecciones',
  'Observaciones objeto asegurado',
] as const;
export const PESTANAS_HOGAR_FIGURAS = [
  'Datos Generales',
  'Domicilios',
  'Formas de contacto',
] as const;
export const PESTANAS_HOGAR_VIVIENDA = [
  'Información Catastro',
  'Datos de la vivienda',
  'Forma aseguramiento',
] as const;
export const PESTANAS_HOGAR_TOMADOR = [
  'Datos Personales',
  'Domicilio',
  'Contacto',
  'Correspondencia',
] as const;
export const PESTANAS_HOGAR_ASEGURADO = ['Datos Personales', 'Domicilio'] as const;
export const PESTANAS_HOGAR_OBSERVACIONES = [
  'Cláusulas generales',
  'Observaciones nivel póliza',
] as const;

export function pestanasPoliza(
  tipoDetalle: TipoDetallePoliza,
  idPoliza: string | null,
  primasPeriodicas = false,
): string[] {
  const conId = Boolean(idPoliza);
  switch (tipoDetalle) {
    case 'AUTOS':
      return conId
        ? ['Vehículos', 'Coberturas', 'Intervinientes', 'Recibos', 'Prestaciones']
        : ['Recibos', 'Prestaciones'];
    case 'SALUD':
      return conId
        ? ['Intervinientes', 'Coberturas', 'Recibos', 'Prestaciones']
        : ['Recibos', 'Prestaciones'];
    case 'VIDA':
      return conId
        ? [
            'Intervinientes',
            'Estructura comercial',
            'Coberturas',
            'Recibos',
            'Prestaciones',
            'Documentos',
            ...(primasPeriodicas ? ['Primas'] : []),
          ]
        : ['Recibos', 'Prestaciones'];
    case 'HOGAR':
      return conId
        ? ['Inf. general', 'Figuras', 'Coberturas', 'Autorizaciones', 'Pagos']
        : ['Recibos', 'Prestaciones'];
    case 'CONSUMO_PROTEGIDO':
    case 'HIPOTECA_SEGURA':
      return conId ? [
        'Inf. General',
        'Inf. Objeto Asegurado',
        'Fig. Participantes',
        'Coberturas/Garantías/Prestaciones',
        'Observaciones y Cláusulas',
        'Autorizaciones',
        'Entorno ec',
      ] : ['Recibos', 'Prestaciones'];
    default:
      return ['Recibos', 'Prestaciones'];
  }
}

/** /polizas/:numero — ficha de póliza (resumen, bloques por ramo, acciones del catálogo y recibos). */
@Component({
  selector: 'pgm-poliza-page',
  imports: [
    DatePipe,
    CurrencyPipe,
    KeyValuePipe,
    RouterLink,
    EstadoComponent,
    IconoComponent,
    TablaExportableComponent,
  ],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    @if (restringida(); as msg) {
      <section class="card">
        <div class="alerta alerta-info" data-testid="restringida">
          <pgm-icono nombre="aviso" [tam]="16" /> {{ msg }}
        </div>
        <a class="btn btn-secundario" routerLink="/inicio">Volver</a>
      </section>
    }
    @if (poliza(); as p) {
      <section class="card">
        <div class="row">
          <h1>Póliza {{ p.numero }} · {{ etiquetas[p.ramo] }}</h1>
          <span
            class="chip"
            [class.chip-ok]="p.estado === 'EN_VIGOR'"
            [class.chip-error]="p.estado === 'ANULADA'"
            >{{ p.estado }}</span
          >
          <span class="spacer"></span>
          <a class="btn btn-secundario" [routerLink]="['/clientes', p.clienteId]"
            >Ficha del cliente</a
          >
          <button class="btn" type="button" data-testid="btn-acciones" (click)="abrirAcciones()">
            {{ t.acciones }}
          </button>
        </div>
        <div class="subtabs" role="tablist" data-testid="pestanas-poliza">
          @for (tab of pestanasPara(p); track tab) {
            <button
              type="button"
              role="tab"
              [class.activa]="pestana() === tab"
              (click)="seleccionarPestana(tab, p)"
            >
              {{ tab }}
            </button>
          }
        </div>
        @if (p.tipoDetalle === 'AUTOS' && pestana() === 'Vehículos') {
          <div class="subtabs" role="tablist" data-testid="subpestanas-autos">
            @for (tab of pestanasDetalleAutos; track tab) {
              <button
                type="button"
                role="tab"
                [class.activa]="seccionDetalle() === tab"
                (click)="seleccionarSeccionDetalle(tab)"
                >{{ tab }}</button
              >
            }
          </div>
        }
        @if (p.tipoDetalle === 'HOGAR' && pestana() === 'Inf. general') {
          <div class="subtabs" role="tablist" data-testid="subpestanas-hogar">
            @for (tab of pestanasDetalleHogar; track tab) {
              <button
                type="button"
                role="tab"
                [class.activa]="seccionDetalle() === tab"
                (click)="seleccionarSeccionDetalle(tab)"
                >{{ tab }}</button
              >
            }
          </div>
        }
        @if (p.tipoDetalle === 'AUTOS' && pestana() === 'Vehículos') {
          <div class="subtabs" role="tablist" data-testid="pestanas-detalle-autos">
            @for (tab of pestanasHijasDetalle(); track tab) {
              <button
                type="button"
                role="tab"
                [class.activa]="pestanaDetalle() === tab"
                (click)="pestanaDetalle.set(tab)"
                >{{ tab }}</button
              >
            }
          </div>
        }
        @if (p.tipoDetalle === 'HOGAR' && pestana() === 'Inf. general') {
          <div class="subtabs" role="tablist" data-testid="pestanas-detalle-hogar">
            @if (seccionDetalle() === 'Tomador/Asegurado') {
              @for (figura of pestanasFiguraHogar; track figura) {
                <button
                  type="button"
                  role="tab"
                  [class.activa]="figuraHogar() === figura"
                  (click)="seleccionarFiguraHogar(figura)"
                  >{{ figura }}</button
                >
              }
            }
            @for (tab of pestanasHijasDetalle(); track tab) {
              <button
                type="button"
                role="tab"
                [class.activa]="pestanaDetalle() === tab"
                (click)="pestanaDetalle.set(tab)"
                >{{ tab }}</button
              >
            }
          </div>
        }
        <h2>{{ t.resumen }}</h2>
        @if (pestana() === 'Recibos') {
          <p>{{ t.recibos }}</p>
        } @else if (pestana() !== 'Prestaciones') {
          <h2>{{ pestana() }}</h2>
        }
        @if (detalle(); as d) {
          @if (pestana() === 'Coberturas' && d.garantias.length) {
            <table class="tabla" data-testid="coberturas-poliza">
              <thead><tr><th>Garantía</th><th>Capital</th><th>Franquicia</th></tr></thead>
              <tbody>
                @for (g of d.garantias; track g.codigo) {
                  <tr>
                    <td>{{ g.nombre }}</td>
                    <td>{{ g.capital !== null ? (g.capital | currency: 'EUR') : 'Incluida' }}</td>
                    <td>{{ g.franquicia ?? '—' }}</td>
                  </tr>
                }
              </tbody>
            </table>
          }
          @if (pestana() === 'Intervinientes' && d.beneficiarios.length) {
            <table class="tabla" data-testid="intervinientes-poliza">
              <thead><tr><th>Beneficiario</th><th>Parentesco</th><th>%</th></tr></thead>
              <tbody>
                @for (b of d.beneficiarios; track $index) {
                  <tr><td>{{ b.nombre }}</td><td>{{ b.parentesco }}</td><td>{{ b.porcentaje }}</td></tr>
                }
              </tbody>
            </table>
          }
          <div class="grid grid-2 bloques" data-testid="bloques-ramo">
            @for (b of bloquesParaPestana(d); track b[0]) {
              <div>
                <h3>{{ b[0] }}</h3>
                <dl class="datos">
                  @for (c of b[1] | keyvalue; track c.key) {
                    <dt>{{ c.key }}</dt>
                    <dd>{{ c.value }}</dd>
                  }
                </dl>
              </div>
            }
          </div>
        }
      </section>
      @if (pestana() === 'Recibos') {
        <section class="card">
        <pgm-tabla-exportable
          [titulo]="t.recibos"
          [nombreFichero]="'recibos-' + p.numero"
          [columnas]="columnas"
          [filas]="recibos()"
        />
        </section>
      }

      @if (dialogoAcciones()) {
        <div class="backdrop" role="presentation">
          <div class="dialogo" role="dialog" aria-modal="true" data-testid="dialogo-acciones">
            <div class="row">
              <pgm-icono nombre="externo" [tam]="20" />
              <h2>{{ etiquetas[p.ramo] }} · {{ p.numero }} · {{ p.producto }}</h2>
            </div>
            <div class="cards">
              @for (a of acciones(); track a.codigo) {
                <button
                  type="button"
                  class="card-accion"
                  [class.activa]="seleccionada()?.codigo === a.codigo"
                  (click)="seleccionada.set(a)"
                >
                  <strong>{{ a.nombre }}</strong>
                  <small class="muted">{{ a.destino }}</small>
                </button>
              } @empty {
                <p class="muted">No hay acciones disponibles para esta póliza.</p>
              }
            </div>
            @if (seleccionada(); as a) {
              @if (a.codigo === 'DOCUMENTACION_EMISION') {
                <button type="button" class="btn" (click)="cargarDocumentos()">
                  {{ t.consultaDescarga }}
                </button>
                @if (documentos(); as docs) {
                  @if (!docs.length) {
                    <p class="muted">{{ t.sinDocumentos }}</p>
                  } @else {
                    <table class="tabla" data-testid="tabla-documentos">
                      <thead>
                        <tr>
                          <th>Documento</th>
                          <th>Tipo</th>
                          <th>Fecha</th>
                          <th>Formato</th>
                        </tr>
                      </thead>
                      <tbody>
                        @for (dc of docs; track dc.id) {
                          <tr>
                            <td>{{ dc.nombre }}</td>
                            <td>{{ dc.tipo }}</td>
                            <td>{{ dc.fecha | date: 'dd/MM/yyyy' }}</td>
                            <td>{{ dc.formato }}</td>
                          </tr>
                        }
                      </tbody>
                    </table>
                  }
                }
              } @else if (a.url) {
                <a
                  class="btn"
                  [href]="a.url"
                  [attr.target]="a.externa ? '_blank' : null"
                  rel="noopener"
                  data-testid="btn-ir"
                  >{{ t.ir }} <pgm-icono nombre="externo" [tam]="14" /> {{ a.destino }}</a
                >
              }
            }
            <div class="botones">
              <button type="button" class="btn btn-secundario" (click)="dialogoAcciones.set(false)">
                {{ t.cerrar }}
              </button>
            </div>
          </div>
        </div>
      }
    }
  `,
  styles: [
    `
      .bloques {
        margin-top: 1rem;
      }
      .bloques h3,
      .dialogo h3 {
        font-size: 0.95rem;
        color: #c8102e;
        margin: 0.5rem 0;
      }
      .backdrop {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 100;
      }
      .dialogo {
        background: #fff;
        border-radius: 6px;
        width: min(52rem, 94vw);
        max-height: 90vh;
        overflow: auto;
        padding: 1.25rem 1.5rem;
      }
      .cards {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(11rem, 1fr));
        gap: 0.75rem;
        margin: 1rem 0;
      }
      .card-accion {
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
        padding: 0.9rem;
        border: 1px solid #ddd;
        border-radius: 6px;
        background: #fff;
        cursor: pointer;
        text-align: left;
        font: inherit;
      }
      .card-accion.activa {
        border-color: #c8102e;
        box-shadow: 0 0 0 2px rgba(200, 16, 46, 0.15);
      }
      .botones {
        display: flex;
        justify-content: flex-end;
        margin-top: 1rem;
      }
      .alerta {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        padding: 0.6rem 0.8rem;
        border-radius: 4px;
        margin-bottom: 1rem;
      }
      .alerta-info {
        background: #eef5fb;
        color: #1d4e89;
      }
    `,
  ],
})
export class PolizaPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly t = TEXTOS_POLIZA;
  readonly numero = input.required<string>();
  readonly poliza = signal<Poliza | null>(null);
  readonly detalle = signal<DetallePolizaRamo | null>(null);
  readonly recibos = signal<Recibo[]>([]);
  readonly acciones = signal<AccionPoliza[]>([]);
  readonly seleccionada = signal<AccionPoliza | null>(null);
  readonly documentos = signal<DocumentoPoliza[] | null>(null);
  readonly dialogoAcciones = signal(false);
  readonly restringida = signal<string | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;
  readonly pestana = signal('');
  readonly pestanaDetalle = signal<string>('');
  readonly seccionDetalle = signal<string>('');
  readonly figuraHogar = signal<'Tomador' | 'Asegurado'>('Tomador');
  readonly pestanasDetalleAutos = PESTANAS_AUTOS_SECCIONES;
  readonly pestanasDetalleHogar = PESTANAS_HOGAR_SECCIONES;
  readonly pestanasFiguraHogar = ['Tomador', 'Asegurado'] as const;
  readonly columnas: Columna<Recibo>[] = [
    { clave: 'numero', titulo: 'Recibo' },
    { clave: 'estado', titulo: 'Estado' },
    { clave: 'importe', titulo: 'Importe (€)' },
    { clave: 'fechaEmision', titulo: 'Emisión' },
    { clave: 'fechaVencimiento', titulo: 'Vencimiento' },
    { clave: 'formaPago', titulo: 'Forma de pago' },
    { clave: 'ibanEnmascarado', titulo: 'IBAN' },
  ];

  constructor() {
    effect(() => void this.cargar(this.numero()));
  }

  async cargar(numero: string): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    this.restringida.set(null);
    this.poliza.set(null);
    try {
      const p = await firstValueFrom(this.repo.fichaPoliza(numero));
      this.poliza.set(p);
      this.pestana.set(this.pestanasPara(p)[0] ?? '');
      const [recibos, detalle] = await Promise.all([
        firstValueFrom(this.repo.recibosPoliza(numero)),
        firstValueFrom(this.repo.detallePolizaRamo(numero)).catch(() => null),
      ]);
      this.recibos.set(recibos.items);
      this.detalle.set(detalle);
      this.pestana.set(this.pestanasPara(p)[0] ?? '');
      this.seccionDetalle.set(
        p.tipoDetalle === 'AUTOS' ? PESTANAS_AUTOS_SECCIONES[0] : PESTANAS_HOGAR_SECCIONES[0],
      );
      this.figuraHogar.set('Tomador');
      this.pestanaDetalle.set(this.pestanasHijasDetalle()[0] ?? '');
    } catch (e) {
      const err = e as { status?: number; error?: { detail?: string }; message?: string };
      if (err.status === 403) {
        this.restringida.set(err.error?.detail ?? 'Ficha de póliza no disponible para tu usuario');
      } else {
        this.error.set(err.error?.detail ?? err.message ?? 'Error al cargar la póliza');
      }
    } finally {
      this.cargando.set(false);
    }
  }

  pestanasPara(p: Poliza, idPoliza?: string | null): string[] {
    const detalle = this.detalle();
    const idPolizaDetalle = idPoliza !== undefined ? idPoliza : detalle?.idPoliza ?? null;
    return pestanasPoliza(
      (p.tipoDetalle ?? 'GENERICA') as TipoDetallePoliza,
      idPolizaDetalle,
      this.detalle()?.primasPeriodicas ?? false,
    );
  }

  bloquesParaPestana(detalle: DetallePolizaRamo): [string, Record<string, string>][] {
    const clavesPorPestana: Record<string, string[]> = {
      Vehículos: ['Vehículo', 'Conductores'],
      Coberturas: ['Coberturas'],
      Intervinientes: ['Intervinientes', 'Figuras', 'Beneficiarios'],
      'Inf. general': ['Vivienda', 'Datos del contrato'],
      'Inf. General': ['Inf. General'],
      'Inf. Objeto Asegurado': ['Objeto asegurado', 'Vivienda'],
      'Fig. Participantes': ['Participantes', 'Intervinientes'],
      'Coberturas/Garantías/Prestaciones': ['Coberturas', 'Garantías', 'Garantias'],
      'Observaciones y Cláusulas': ['Observaciones', 'Cláusulas'],
      'Estructura comercial': ['Estructura comercial'],
    };
    const claves = clavesPorPestana[this.pestana()] ?? [
      this.pestana(),
      this.seccionDetalle(),
      this.pestanaDetalle(),
    ];
    const normalizar = (texto: string) => texto.trim().toLocaleLowerCase('es');
    return Object.entries(detalle.bloques).filter(([clave]) =>
      claves.some((esperada) => normalizar(clave) === normalizar(esperada)),
    );
  }

  seleccionarPestana(tab: string, poliza: Poliza): void {
    this.pestana.set(tab);
    this.seccionDetalle.set(
      poliza.tipoDetalle === 'AUTOS' ? PESTANAS_AUTOS_SECCIONES[0] : PESTANAS_HOGAR_SECCIONES[0],
    );
    this.pestanaDetalle.set(this.pestanasHijasDetalle()[0] ?? '');
  }

  seleccionarSeccionDetalle(tab: string): void {
    this.seccionDetalle.set(tab);
    this.pestanaDetalle.set(this.pestanasHijasDetalle()[0] ?? '');
  }

  seleccionarFiguraHogar(figura: 'Tomador' | 'Asegurado'): void {
    this.figuraHogar.set(figura);
    this.pestanaDetalle.set(this.pestanasHijasDetalle()[0] ?? '');
  }

  pestanasHijasDetalle(): readonly string[] {
    if (this.detalle()?.tipoDetalle === 'AUTOS') {
      switch (this.seccionDetalle()) {
        case 'Inf. general':
          return PESTANAS_AUTOS_INFO_GENERAL;
        case 'Riesgo':
          return PESTANAS_AUTOS_RIESGO;
        case 'Figuras tomador':
          return PESTANAS_AUTOS_FIGURAS_TOMADOR;
        case 'Observaciones':
          return PESTANAS_AUTOS_OBSERVACIONES;
        default:
          return [];
      }
    }
    switch (this.seccionDetalle()) {
      case 'Riesgo':
        return PESTANAS_HOGAR_RIESGO;
      case 'Figuras':
        return PESTANAS_HOGAR_FIGURAS;
      case 'Vivienda':
        return PESTANAS_HOGAR_VIVIENDA;
      case 'Tomador/Asegurado':
        return this.figuraHogar() === 'Tomador'
          ? PESTANAS_HOGAR_TOMADOR
          : PESTANAS_HOGAR_ASEGURADO;
      case 'Observaciones':
        return PESTANAS_HOGAR_OBSERVACIONES;
      default:
        return [];
    }
  }

  async abrirAcciones(): Promise<void> {
    this.seleccionada.set(null);
    this.documentos.set(null);
    this.dialogoAcciones.set(true);
    const lista = await firstValueFrom(this.repo.accionesPoliza(this.numero()));
    this.acciones.set(lista.items);
  }

  async cargarDocumentos(): Promise<void> {
    const lista = await firstValueFrom(this.repo.documentosPoliza(this.numero()));
    this.documentos.set(lista.items);
  }
}
