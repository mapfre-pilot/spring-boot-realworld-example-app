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
  Prestacion,
  Recibo,
} from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';

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
export type TipoDetallePoliza = 'AUTOS' | 'SALUD' | 'VIDA' | 'HOGAR' | 'GENERICA';

export interface ResultadoDispatcherPoliza {
  tipoDetalle: TipoDetallePoliza;
  pestanas: string[];
}

export function dispatchPestanasPoliza(
  ramo: string,
  numeroPoliza: string,
  idPoliza: string | null,
  primasPeriodicas = false,
): ResultadoDispatcherPoliza {
  let tipoDetalle: TipoDetallePoliza;
  if (ramo === 'SALUD') {
    tipoDetalle = 'SALUD';
  } else if (ramo.includes('AUTOS')) {
    tipoDetalle = 'AUTOS';
  } else if (
    (ramo.includes('RIESGO') || ramo.includes('AHORRO')) &&
    numeroPoliza.length <= 11
  ) {
    tipoDetalle = 'VIDA';
  } else if (ramo.includes('HOGAR')) {
    tipoDetalle = 'HOGAR';
  } else {
    tipoDetalle = 'GENERICA';
  }

  if (tipoDetalle === 'HOGAR') return { tipoDetalle, pestanas: [] };
  if (!idPoliza) return { tipoDetalle, pestanas: ['Recibos', 'Prestaciones'] };
  if (tipoDetalle === 'SALUD') {
    return { tipoDetalle, pestanas: ['Intervinientes', 'Coberturas', 'Recibos', 'Prestaciones'] };
  }
  if (tipoDetalle === 'AUTOS') {
    return {
      tipoDetalle,
      pestanas: ['Vehículos', 'Coberturas', 'Intervinientes', 'Recibos', 'Prestaciones'],
    };
  }
  if (tipoDetalle === 'VIDA') {
    return {
      tipoDetalle,
      pestanas: [
        'Intervinientes',
        'Estructura comercial',
        'Coberturas',
        'Recibos',
        'Prestaciones',
        'Documentos',
        ...(primasPeriodicas ? ['Primas'] : []),
      ],
    };
  }
  return { tipoDetalle, pestanas: ['Recibos', 'Prestaciones'] };
}

/** /polizas/:numero — ficha de póliza (resumen, bloques por ramo, acciones del catálogo y recibos). */
@Component({
  selector: 'pgm-poliza-page',
  imports: [
    CurrencyPipe,
    DatePipe,
    KeyValuePipe,
    RouterLink,
    EstadoComponent,
    IconoComponent,
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
        @if (pestanasPara(p).length) {
        <div class="subtabs" role="tablist" data-testid="pestanas-poliza">
          @for (tab of pestanasPara(p); track tab) {
            <button
              type="button"
              role="tab"
              [class.activa]="pestana() === tab"
              (click)="pestana.set(tab)"
            >
              {{ tab }}
            </button>
          }
        </div>
        }
        <h2>{{ t.resumen }}</h2>
        @if (pestana() === 'Recibos') {
          <p>{{ t.recibos }}</p>
        } @else if (pestana() && pestana() !== 'Prestaciones') {
          <h2>{{ pestana() }}</h2>
        }
        @if (detalle(); as d) {
          @if (pestana() === 'Coberturas' && d.garantias.length) {
            <table class="tabla" data-testid="coberturas-poliza">
              <thead><tr>
                @for (columna of columnasCoberturas(p); track columna) {
                  <th>{{ columna }}</th>
                }
              </tr></thead>
              <tbody>
                @for (g of d.garantias; track g.codigo) {
                  <tr>
                    @for (columna of columnasCoberturas(p); track columna) {
                      <td>{{ valorCobertura(g, columna) }}</td>
                    }
                  </tr>
                }
              </tbody>
            </table>
          }
          @if (pestana() === 'Intervinientes' && (d.beneficiarios.length || p.tipoDetalle !== 'VIDA')) {
            @if (p.tipoDetalle !== 'VIDA') {
              <h3>Intervinientes ({{ d.beneficiarios.length }})</h3>
            }
            <table class="tabla" data-testid="intervinientes-poliza">
              <thead><tr>
                @for (columna of columnasIntervinientes(p); track columna) {
                  <th>{{ columna }}</th>
                }
              </tr></thead>
              <tbody>
                @for (b of d.beneficiarios; track $index) {
                  <tr>
                    @for (columna of columnasIntervinientes(p); track columna) {
                      <td>{{ valorInterviniente(b, columna) }}</td>
                    }
                  </tr>
                }
              </tbody>
            </table>
          }
          @if (p.tipoDetalle === 'VIDA' && pestana() === 'Estructura comercial') {
            <table class="tabla" data-testid="estructura-comercial">
              <thead><tr>@for (columna of columnasEstructuraComercial; track columna) { <th>{{ columna }}</th> }</tr></thead>
              <tbody><tr>@for (columna of columnasEstructuraComercial; track columna) { <td>{{ valorCampo(d, columna) }}</td> }</tr></tbody>
            </table>
          }
          @if (p.tipoDetalle === 'VIDA' && pestana() === 'Documentos') {
            <div class="botones">
              <button type="button" class="btn" (click)="abrirAcciones()">Duplicado de póliza</button>
              <button type="button" class="btn btn-secundario" (click)="cargarDocumentos()">Lector de documentos</button>
            </div>
            @if (documentos(); as docs) {
              @for (documento of docs; track documento.id) {
                <p>{{ documento.nombre }}</p>
              }
            }
          }
          @if (p.tipoDetalle === 'VIDA' && pestana() === 'Primas') {
            <dl class="datos">
              @for (campo of camposPrimasVida; track campo) {
                <dt>{{ campo }}</dt>
                <dd>{{ valorCampo(d, campo) }}</dd>
              }
            </dl>
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
          <table class="tabla" data-testid="recibos-poliza">
            <thead><tr><th>Icono ramo</th><th>Método de pago</th><th>Importe</th><th>Fechas</th><th>Estado</th></tr></thead>
            <tbody>
              @for (recibo of recibos(); track recibo.numero) {
                <tr>
                  <td>{{ recibo.ramo }}</td>
                  <td>{{ recibo.formaPago }}</td>
                  <td>{{ recibo.importe | currency: 'EUR' }}</td>
                  <td>Nº recibo {{ recibo.numero }} · Inicio {{ recibo.fechaEmision | date: 'dd/MM/yyyy' }} · Fin {{ recibo.fechaVencimiento | date: 'dd/MM/yyyy' }}</td>
                  <td>{{ recibo.estado }}</td>
                </tr>
              }
            </tbody>
          </table>
        </section>
      }
      @if (pestana() === 'Prestaciones') {
        <section class="card">
          <table class="tabla" data-testid="prestaciones-poliza">
            <thead><tr><th>Icono ramo</th><th>Descripción prestación</th><th>Importe</th><th>Fechas</th><th>Estado</th><th>Acciones</th></tr></thead>
            <tbody>
              @for (prestacion of prestaciones(); track prestacion.numero) {
                <tr>
                  <td>{{ prestacion.ramo }}</td>
                  <td>{{ prestacion.descripcion }}</td>
                  <td></td>
                  <td>No. expediente {{ prestacion.numero }} · Ocurrencia {{ prestacion.fechaOcurrencia | date: 'dd/MM/yyyy' }} · Apertura {{ prestacion.fechaApertura | date: 'dd/MM/yyyy' }}</td>
                  <td>{{ prestacion.estado }}</td>
                  <td></td>
                </tr>
              }
            </tbody>
          </table>
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
  readonly prestaciones = signal<Prestacion[]>([]);
  readonly acciones = signal<AccionPoliza[]>([]);
  readonly seleccionada = signal<AccionPoliza | null>(null);
  readonly documentos = signal<DocumentoPoliza[] | null>(null);
  readonly dialogoAcciones = signal(false);
  readonly restringida = signal<string | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;
  readonly pestana = signal('');
  readonly columnasEstructuraComercial = [
    'Intervinientes',
    'Aport.',
    'Clave productor',
    'TP',
    'O.D.',
    'F. inicio',
    'Nombre',
    'Año 1',
    'Año 2',
    'Nº Sucesivos',
    'Sucesivos (%)',
  ];
  readonly camposPrimasVida = [
    'Prima única',
    'Prima periódica',
    'Importe aportación',
    'Periodicidad aportación',
    'Tipo Revalorizacíon',
    '% Revalorización',
    'Día de cobro',
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
      const [recibos, detalle, prestaciones] = await Promise.all([
        firstValueFrom(this.repo.recibosPoliza(numero)),
        firstValueFrom(this.repo.detallePolizaRamo(numero)).catch(() => null),
        firstValueFrom(this.repo.prestacionesCliente(p.clienteId))
          .then((lista) => lista.items.filter((item) => item.polizaNumero === numero))
          .catch(() => []),
      ]);
      this.recibos.set(recibos.items);
      this.detalle.set(detalle);
      this.prestaciones.set(prestaciones);
      this.pestana.set(this.pestanasPara(p)[0] ?? '');
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
    return dispatchPestanasPoliza(
      p.ramo,
      p.numero,
      idPolizaDetalle,
      this.detalle()?.primasPeriodicas ?? false,
    ).pestanas;
  }

  bloquesParaPestana(detalle: DetallePolizaRamo): [string, Record<string, string>][] {
    const clavesPorPestana: Record<string, string[]> = {
      Vehículos: ['Vehículo', 'Vehículos', 'Riesgo', 'Datos del tomador'],
      Coberturas: ['Coberturas', 'Garantías', 'Garantias'],
      Intervinientes: ['Intervinientes', 'Figuras', 'Beneficiarios', 'Datos del tomador', 'Datos del asegurado'],
      'Estructura comercial': ['Estructura comercial'],
      Documentos: ['Documentos'],
      Primas: ['Primas'],
    };
    const claves = clavesPorPestana[this.pestana()] ?? [this.pestana()];
    const normalizar = (texto: string) => texto.trim().toLocaleLowerCase('es');
    return Object.entries(detalle.bloques).filter(([clave]) =>
      claves.some((esperada) => normalizar(clave) === normalizar(esperada)),
    );
  }

  columnasCoberturas(poliza: Poliza): string[] {
    if (poliza.tipoDetalle === 'AUTOS') return ['Descripción', 'Suma'];
    if (poliza.tipoDetalle === 'SALUD') return ['Nombre', 'Cobertura', 'Obligatoria', 'Contratada'];
    if (poliza.tipoDetalle === 'VIDA') {
      return ['Garantía', 'Capital/Renta', 'Prima neta anual', 'Fondo', 'Títulos', 'Importe', 'VLP', 'Fecha VLP'];
    }
    return [];
  }

  columnasIntervinientes(poliza: Poliza): string[] {
    return poliza.tipoDetalle === 'VIDA'
      ? ['Suceso', 'Beneficiarios', '%']
      : ['Nombre', 'Tipo de Documento', 'Nº Documento', 'Fecha Nacimiento', 'Figura'];
  }

  valorInterviniente(
    beneficiario: DetallePolizaRamo['beneficiarios'][number],
    columna: string,
  ): string {
    if (columna === 'Suceso') return beneficiario.parentesco;
    if (columna === 'Beneficiarios' || columna === 'Nombre') return beneficiario.nombre;
    if (columna === 'Nº Documento') return beneficiario.documento;
    if (columna === '%') return String(beneficiario.porcentaje);
    if (columna === 'Figura') return beneficiario.parentesco;
    return '';
  }

  valorCobertura(garantia: DetallePolizaRamo['garantias'][number], columna: string): string {
    if (columna === 'Descripción' || columna === 'Nombre' || columna === 'Garantía') {
      return garantia.nombre;
    }
    if (columna === 'Suma' || columna === 'Capital/Renta' || columna === 'Importe') {
      return garantia.capital === null ? '' : String(garantia.capital);
    }
    return '';
  }

  valorCampo(detalle: DetallePolizaRamo, campo: string): string {
    const buscado = campo.trim().toLocaleLowerCase('es');
    for (const bloque of Object.values(detalle.bloques)) {
      const entrada = Object.entries(bloque).find(([clave]) => clave.trim().toLocaleLowerCase('es') === buscado);
      if (entrada) return entrada[1];
    }
    return '';
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
