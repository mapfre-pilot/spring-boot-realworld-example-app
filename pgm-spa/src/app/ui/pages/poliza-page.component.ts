import { CurrencyPipe, DatePipe } from '@angular/common';
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

type TipoCajaPoliza = 'campos' | 'garantias' | 'intervinientes' | 'beneficiarios' | 'recibos' | 'prestaciones' | 'documentos';

interface CajaPolizaSAIL {
  titulo: string;
  tipo: TipoCajaPoliza;
  bloque?: string;
  campos?: string[];
  columnas?: string[];
  contador?: 'garantias' | 'intervinientes' | 'recibos' | 'prestaciones';
}

export const VISTAS_POLIZA_SAIL: Record<TipoDetallePoliza, Record<string, CajaPolizaSAIL[]>> = {
  AUTOS: {
    Vehículos: [
      { titulo: '$riesgo', tipo: 'campos', bloque: 'Vehículo', campos: ['Marca', 'Matrícula', 'Modelo', 'Número de bastidor', 'Color', 'Código vehículo', 'Tipo de vehículo', 'Referencia vehículo', 'Información detallada del vehículo', 'Número de puertas', 'Número de caballos', 'Combustible', 'Cilindrada', 'Tipo de cambio', 'Precio de venta'] },
      { titulo: 'Tomador', tipo: 'campos', bloque: 'Datos del tomador', campos: ['Nombre', 'NIF/CIF', 'Genero', 'F. Nacimiento', 'Email', 'Tlfn. Móvil', 'Dirección'] },
    ],
    Coberturas: [
      { titulo: 'Coberturas y garantias', tipo: 'garantias', contador: 'garantias', columnas: ['Coberturas', 'Suma asegurada'] },
    ],
    Intervinientes: [
      { titulo: 'Tomador', tipo: 'campos', bloque: 'Datos del tomador', campos: ['Nombre', 'NIF/CIF', 'Genero', 'F. Nacimiento', 'Email', 'Tlfn. Móvil', 'Dirección'] },
      { titulo: 'Intervinientes', tipo: 'intervinientes', contador: 'intervinientes', columnas: ['Nombre', 'Tipo de Documento', 'Nº Documento', 'Fecha Nacimiento', 'Figura'] },
    ],
    Recibos: [
      { titulo: 'Recibos', tipo: 'recibos', contador: 'recibos', columnas: ['Nº recibo', 'Método de pago', 'Importe', 'Inicio', 'Fin', 'Estado'] },
    ],
    Prestaciones: [
      { titulo: 'Prestaciones', tipo: 'prestaciones', contador: 'prestaciones', columnas: ['No. expediente', 'Descripción prestación', 'Importe', 'Ocurrencia', 'Apertura', 'Estado', 'Acciones'] },
    ],
  },
  SALUD: {
    Intervinientes: [
      { titulo: 'Datos del tomador', tipo: 'campos', bloque: 'Datos del tomador', campos: ['Nº Documento', 'Dirección', 'Estado Civil', 'Sexo', 'Fecha de nacimiento', 'Número de teléfono personal'] },
      { titulo: 'Intervinientes', tipo: 'intervinientes', contador: 'intervinientes', columnas: ['Nombre', 'Tipo de Documento', 'Nº Documento', 'Fecha Nacimiento', 'Figura'] },
    ],
    Coberturas: [
      { titulo: 'Coberturas contratadas', tipo: 'garantias', columnas: ['Nombre', 'Cobertura', 'Obligatoria', 'Contratada'] },
    ],
    Recibos: [
      { titulo: 'Recibos', tipo: 'recibos', contador: 'recibos', columnas: ['Nº recibo', 'Método de pago', 'Importe', 'Inicio', 'Fin', 'Estado'] },
    ],
    Prestaciones: [
      { titulo: 'Prestaciones', tipo: 'prestaciones', contador: 'prestaciones', columnas: ['No. expediente', 'Descripción prestación', 'Importe', 'Ocurrencia', 'Apertura', 'Estado', 'Acciones'] },
    ],
  },
  VIDA: {
    Intervinientes: [
      { titulo: 'Tomador', tipo: 'campos', bloque: 'Datos del tomador', campos: ['El Tomador es asegurado', 'Nombre y apellidos', 'NIF/CIF', 'Profesión', 'F. Nacimiento', 'Tlfn. Particular', 'Tlfn. Móvil', 'Preguntas', '¿Tiene establecida su residencia habitual en España?', '¿Es o ha sido persona de responsabilidad pública, familiar en primer grado o allegado a ésta por relación personal o empresarial?', '¿Es residente fiscal en terceros países?', 'Domicilio', 'Fiscal', 'Cobro', 'Prestación', 'Comunicación'] },
      { titulo: 'Asegurados', tipo: 'campos', bloque: 'Datos del asegurado', campos: ['Nombre y apellidos', 'NIF/CIF', 'Profesión', 'F. Nacimiento', 'Sexo'] },
      { titulo: 'Beneficiarios', tipo: 'beneficiarios', columnas: ['Suceso', 'Beneficiarios'] },
    ],
    'Estructura comercial': [
      { titulo: 'Datos', tipo: 'campos', bloque: 'Estructura comercial', columnas: ['Intervinientes', 'Aport.', 'Clave productor', 'TP', 'O.D.', 'F. inicio', 'Nombre', 'Año 1', 'Año 2', 'Nº Sucesivos', 'Sucesivos (%)'] },
    ],
    Coberturas: [
      { titulo: 'Garantias y capitales', tipo: 'garantias', contador: 'garantias', columnas: ['Garantía', 'Capital/Renta', 'Prima neta anual', 'Fondo', '%', 'Títulos', 'Importe', 'VLP', 'Fecha VLP'] },
    ],
    Recibos: [
      { titulo: 'Recibos', tipo: 'recibos', contador: 'recibos', columnas: ['Nº recibo', 'Método de pago', 'Importe', 'Inicio', 'Fin', 'Estado'] },
    ],
    Prestaciones: [
      { titulo: 'Prestaciones', tipo: 'prestaciones', columnas: ['No. expediente', 'Descripción prestación', 'Importe', 'Ocurrencia', 'Apertura', 'Estado', 'Acciones'] },
    ],
    Documentos: [{ titulo: 'Documentos', tipo: 'documentos' }],
    Primas: [
      { titulo: 'Primas', tipo: 'campos', bloque: 'Primas', campos: ['Prima única', 'Prima periódica', 'Importe aportación', 'Periodicidad aportación', 'Tipo Revalorizacíon', '% Revalorización', 'Día de cobro'] },
    ],
  },
  HOGAR: {},
  GENERICA: {
    Recibos: [
      { titulo: 'Recibos', tipo: 'recibos', contador: 'recibos', columnas: ['Nº recibo', 'Método de pago', 'Importe', 'Inicio', 'Fin', 'Estado'] },
    ],
    Prestaciones: [
      { titulo: 'Prestaciones', tipo: 'prestaciones', contador: 'prestaciones', columnas: ['No. expediente', 'Descripción prestación', 'Importe', 'Ocurrencia', 'Apertura', 'Estado', 'Acciones'] },
    ],
  },
};

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
        <dl class="datos poliza-cabecera" data-testid="cabecera-poliza">
          <dt>Ramo</dt><dd>{{ p.ramo }}</dd>
          <dt>Producto comercial</dt><dd>{{ p.producto }}</dd>
          <dt>Descripción del riesgo</dt><dd>{{ valorSeguro(p.riesgo) }}</dd>
          <dt>Prima</dt><dd>{{ p.primaAnual | currency: 'EUR' }}</dd>
          <dt>Estado</dt><dd>{{ p.estado }}</dd>
          <dt>Fecha efecto/vencimiento</dt><dd>{{ p.fechaEfecto | date: 'dd/MM/yyyy' }} / {{ p.fechaVencimiento | date: 'dd/MM/yyyy' }}</dd>
          <dt>Forma de pago</dt><dd>{{ valorSeguro(p.formaPago) }}</dd>
        </dl>
        @if (detalle(); as d) {
          @for (caja of cajasParaPestana(p, d); track $index) {
            <section class="poliza-caja" [attr.data-testid]="'caja-' + caja.titulo">
              <h2>{{ tituloCaja(caja, d, p) }}</h2>
              @if (caja.tipo === 'campos') {
                @if (caja.columnas?.length) {
                  <table class="tabla" data-testid="estructura-comercial">
                    <thead><tr>@for (columna of caja.columnas; track columna) { <th>{{ columna }}</th> }</tr></thead>
                    <tbody><tr>@for (columna of caja.columnas; track columna) { <td>{{ valorBloque(d, caja.bloque, columna) }}</td> }</tr></tbody>
                  </table>
                } @else {
                  <dl class="datos">
                    @for (campo of caja.campos ?? []; track campo) {
                      <dt>{{ campo }}</dt><dd>{{ valorBloque(d, caja.bloque, campo) }}</dd>
                    }
                  </dl>
                }
              } @else if (caja.tipo === 'garantias') {
                <table class="tabla" data-testid="coberturas-poliza">
                  <thead><tr>@for (columna of caja.columnas ?? []; track columna) { <th>{{ columna }}</th> }</tr></thead>
                  <tbody>@for (garantia of d.garantias; track garantia.codigo) {
                    <tr>@for (columna of caja.columnas ?? []; track columna) { <td>{{ valorCobertura(d, garantia, columna) }}</td> }</tr>
                  }</tbody>
                </table>
              } @else if (caja.tipo === 'intervinientes' || caja.tipo === 'beneficiarios') {
                <table class="tabla" data-testid="intervinientes-poliza">
                  <thead><tr>@for (columna of caja.columnas ?? []; track columna) { <th>{{ columna }}</th> }</tr></thead>
                  <tbody>
                    @if (caja.tipo === 'beneficiarios') {
                      @for (fila of d.beneficiarios; track $index) {
                        <tr>@for (columna of caja.columnas ?? []; track columna) { <td>{{ valorBeneficiario(fila, columna) }}</td> }</tr>
                      }
                    } @else {
                      @for (fila of filasIntervinientes(d); track $index) {
                        <tr>@for (columna of caja.columnas ?? []; track columna) { <td>{{ valorFila(fila, columna) }}</td> }</tr>
                      }
                    }
                  </tbody>
                </table>
              } @else if (caja.tipo === 'recibos') {
                <table class="tabla" data-testid="recibos-poliza">
                  <thead><tr>@for (columna of caja.columnas ?? []; track columna) { <th>{{ columna }}</th> }</tr></thead>
                  <tbody>@for (recibo of recibos(); track recibo.numero) {
                    <tr>@for (columna of caja.columnas ?? []; track columna) { <td>{{ valorRecibo(recibo, columna) }}</td> }</tr>
                  }</tbody>
                </table>
              } @else if (caja.tipo === 'prestaciones') {
                <table class="tabla" data-testid="prestaciones-poliza">
                  <thead><tr>@for (columna of caja.columnas ?? []; track columna) { <th>{{ columna }}</th> }</tr></thead>
                  <tbody>@for (prestacion of prestaciones(); track prestacion.numero) {
                    <tr>@for (columna of caja.columnas ?? []; track columna) { <td>{{ valorPrestacion(prestacion, columna) }}</td> }</tr>
                  }</tbody>
                </table>
              } @else if (caja.tipo === 'documentos') {
                <div class="botones">
                  <button type="button" class="btn" (click)="abrirAcciones()">Duplicado de póliza</button>
                  <button type="button" class="btn btn-secundario" (click)="cargarDocumentos()">Lector de documentos</button>
                </div>
                @if (documentos(); as docs) { @for (documento of docs; track documento.id) { <p>{{ documento.nombre }}</p> } }
              }
            </section>
          }
        }
      </section>

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
      .poliza-cabecera {
        margin-top: 1rem;
      }
      .poliza-caja {
        margin-top: 1rem;
        padding-top: 0.75rem;
        border-top: 1px solid #e2e5e7;
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

  cajasParaPestana(poliza: Poliza, detalle: DetallePolizaRamo): CajaPolizaSAIL[] {
    if (!poliza.tipoDetalle || poliza.tipoDetalle === 'HOGAR' || !this.pestana()) return [];
    const cajas = VISTAS_POLIZA_SAIL[poliza.tipoDetalle][this.pestana()] ?? [];
    if (poliza.tipoDetalle !== 'VIDA' || this.pestana() !== 'Intervinientes') return cajas;
    const tomadorAsegurado = detalle.bloques?.['Datos del tomador']?.['El Tomador es asegurado'];
    return cajas.filter((caja) => caja.titulo !== 'Asegurados' || tomadorAsegurado?.toLowerCase() === 'false');
  }

  tituloCaja(caja: CajaPolizaSAIL, detalle: DetallePolizaRamo, poliza: Poliza): string {
    const titulo = caja.titulo === '$riesgo' ? this.valorSeguro(poliza.riesgo) : caja.titulo;
    if (!caja.contador) return titulo;
    const cuenta = {
      garantias: detalle.garantias?.length ?? 0,
      intervinientes: this.filasIntervinientes(detalle).length,
      recibos: this.recibos().length,
      prestaciones: this.prestaciones().length,
    }[caja.contador];
    return `${titulo} (${cuenta})`;
  }

  valorBloque(detalle: DetallePolizaRamo, bloque: string | undefined, campo: string): string {
    if (!bloque) return 'No disponible';
    return this.valorSeguro(detalle.bloques?.[bloque]?.[campo]);
  }

  filasIntervinientes(detalle: DetallePolizaRamo): Record<string, string>[] {
    return Object.entries(detalle.bloques ?? {})
      .filter(([clave]) => clave.startsWith('Interviniente '))
      .map(([, fila]) => fila);
  }

  valorFila(fila: Record<string, string>, campo: string): string {
    return this.valorSeguro(fila[campo]);
  }

  valorBeneficiario(beneficiario: DetallePolizaRamo['beneficiarios'][number], campo: string): string {
    if (campo === 'Suceso') return this.valorSeguro(beneficiario.parentesco);
    if (campo === 'Beneficiarios') return this.valorSeguro(beneficiario.nombre);
    return 'No disponible';
  }

  valorCobertura(detalle: DetallePolizaRamo, garantia: DetallePolizaRamo['garantias'][number], columna: string): string {
    if (columna === 'Coberturas' || columna === 'Nombre' || columna === 'Garantía') return this.valorSeguro(garantia.nombre);
    if (columna === 'Suma asegurada' || columna === 'Capital/Renta') {
      return garantia.capital == null ? this.valorSeguro(garantia.franquicia) : String(garantia.capital);
    }
    return this.valorSeguro(detalle.bloques?.[`Garantía ${garantia.codigo}`]?.[columna]);
  }

  valorRecibo(recibo: Recibo, columna: string): string {
    const valores: Record<string, unknown> = {
      'Nº recibo': recibo.numero,
      'Método de pago': recibo.formaPago,
      Importe: recibo.importe == null ? null : `${recibo.importe} €`,
      Inicio: recibo.fechaEmision,
      Fin: recibo.fechaVencimiento,
      Estado: recibo.estado,
    };
    return this.valorSeguro(valores[columna]);
  }

  valorPrestacion(prestacion: Prestacion, columna: string): string {
    const valores: Record<string, unknown> = {
      'No. expediente': prestacion.numero,
      'Descripción prestación': prestacion.descripcion,
      Importe: 'No disponible',
      Ocurrencia: prestacion.fechaOcurrencia,
      Apertura: prestacion.fechaApertura,
      Estado: prestacion.estado,
      Acciones: 'No disponible',
    };
    return this.valorSeguro(valores[columna]);
  }

  valorSeguro(valor: unknown): string {
    if (valor === null || valor === undefined || valor === '') return 'No disponible';
    if (typeof valor === 'object') return 'No disponible';
    return String(valor);
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
