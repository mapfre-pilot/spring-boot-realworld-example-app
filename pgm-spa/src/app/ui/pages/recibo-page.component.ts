import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { AccionRecibo, Recibo, ReciboDetalle } from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';

/** Textos literales del menú ⋮ del recibo en PGM (área B). */
export const TEXTOS_RECIBO = {
  consultaRecibos: 'Consulta Recibos',
  visualizarDuplicado: 'Visualizar duplicado',
  detalle: 'Detalle del recibo',
  duplicadoGenerado: 'Duplicado generado',
};
export const PESTANAS_RECIBO = ['Datos Generales', 'Desglose económico', 'Gestiones'] as const;
export const PESTANAS_PAGADOR = ['Datos Personales', 'Contacto', 'Correspondencia'] as const;

/** /recibos/:numero — detalle del recibo con el menú de acciones de PGM. */
@Component({
  selector: 'pgm-recibo-page',
  imports: [DatePipe, CurrencyPipe, RouterLink, EstadoComponent, IconoComponent],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    @if (recibo(); as r) {
      <section class="card">
        <div class="row">
          <h1>Recibo {{ r.numero }}</h1>
          <span
            class="chip"
            [class.chip-ok]="r.estado === 'COBRADO'"
            [class.chip-aviso]="r.estado === 'PENDIENTE'"
            [class.chip-error]="r.estado === 'DEVUELTO'"
            >{{ r.estado }}</span
          >
          <span class="spacer"></span>
          <a class="btn btn-secundario" [routerLink]="['/polizas', r.polizaNumero]"
            >Póliza {{ r.polizaNumero }}</a
          >
          <a class="btn btn-secundario" [routerLink]="['/clientes', r.clienteId]"
            >Ficha del cliente</a
          >
          <details class="menu-recibo" [open]="menuAbierto()">
            <summary
              class="btn btn-secundario"
              aria-label="Acciones del recibo"
              data-testid="menu-recibo"
            >
              ⋮
            </summary>
            <div class="menu" role="menu">
              @for (a of acciones(); track a.codigo) {
                @if (a.tipo === 'EXTERNA' && a.url) {
                  <a role="menuitem" [href]="a.url" target="_blank" rel="noopener"
                    >{{ a.nombre }} <pgm-icono nombre="externo" [tam]="13"
                  /></a>
                } @else {
                  <button type="button" role="menuitem" (click)="ejecutar(a)">
                    {{ a.nombre }}
                  </button>
                }
              }
            </div>
          </details>
        </div>
        <div class="subtabs" role="tablist" data-testid="pestanas-recibo">
          @for (tab of pestanas; track tab) {
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
        @if (mensaje(); as m) {
          <div
            class="alerta"
            [class.alerta-ok]="!esError()"
            [class.alerta-error]="esError()"
            data-testid="mensaje"
          >
            <pgm-icono nombre="aviso" [tam]="16" /> {{ m }}
          </div>
        }
        @switch (pestana()) {
          @case ('Datos Generales') {
            <dl class="datos" data-testid="datos-generales-recibo">
              <dt>Ramo</dt>
              <dd>{{ etiquetas[r.ramo] }}</dd>
              <dt>Emisión</dt>
              <dd>{{ r.fechaEmision | date: 'dd/MM/yyyy' }}</dd>
              <dt>Vencimiento</dt>
              <dd>{{ r.fechaVencimiento | date: 'dd/MM/yyyy' }}</dd>
              <dt>Forma de pago</dt>
              <dd>{{ r.formaPago }}</dd>
              <dt>Pagador</dt>
              <dd>
                <button type="button" class="btn-enlace" (click)="pagadorAbierto.set(true)">
                  Datos del pagador
                </button>
              </dd>
            </dl>
          }
          @case ('Desglose económico') {
            <dl class="datos" data-testid="desglose-economico-recibo">
              <dt>Importe</dt>
              <dd>
                <strong>{{ r.importe | currency: 'EUR' }}</strong>
              </dd>
              <dt>IBAN</dt>
              <dd>{{ r.ibanEnmascarado ?? '—' }}</dd>
              @if (detalle(); as d) {
                <dt>Cuota</dt>
                <dd>{{ d.cuota | currency: 'EUR' }}</dd>
                <dt>Comisiones</dt>
                <dd>{{ d.comisiones | currency: 'EUR' }}</dd>
              }
            </dl>
          }
          @case ('Gestiones') {
            @if (detalle(); as d) {
              <ul data-testid="gestiones-recibo">
                @for (gestion of d.gestiones; track gestion) {
                  <li>{{ gestion }}</li>
                }
              </ul>
            }
          }
        }
      </section>
      @if (pagadorAbierto()) {
        <div class="backdrop" role="presentation">
          <div class="dialogo" role="dialog" aria-modal="true" data-testid="dialogo-pagador">
            <h2>Datos del pagador</h2>
            <div class="subtabs">
              @for (tab of pestanasPagador; track tab) {
                <button
                  type="button"
                  [class.activa]="pestanaPagador() === tab"
                  (click)="pestanaPagador.set(tab)"
                >
                  {{ tab }}
                </button>
              }
            </div>
            @switch (pestanaPagador()) {
              @case ('Datos Personales') {
                @for (disponibilidad of disponibilidadPagador(pestanaPagador()); track disponibilidad.origen) {
                  <p class="alerta alerta-info">{{ disponibilidad.origen }}: {{ disponibilidad.motivo }}</p>
                }
                <dl class="datos">
                  <dt>¿Actua como asegurado?</dt>
                  <dd>—</dd>
                  <dt>Nombre y apellidos</dt>
                  <dd>{{ detalle()?.pagador ?? '—' }}</dd>
                  <dt>Tipo de documento</dt>
                  <dd>—</dd>
                  <dt>Nº de documento</dt>
                  <dd>—</dd>
                  <dt>Fecha de nacimiento</dt>
                  <dd>—</dd>
                  <dt>Nacionalidad</dt>
                  <dd>—</dd>
                  <dt>Sexo</dt>
                  <dd>—</dd>
                  <dt>Tipo de persona</dt>
                  <dd>—</dd>
                  <dt>Estado civil</dt>
                  <dd>—</dd>
                  <dt>Idioma</dt>
                  <dd>—</dd>
                </dl>
              }
              @case ('Contacto') {
                @for (disponibilidad of disponibilidadPagador(pestanaPagador()); track disponibilidad.origen) {
                  <p class="alerta alerta-info">{{ disponibilidad.origen }}: {{ disponibilidad.motivo }}</p>
                }
                <dl class="datos">
                  <dt>Email</dt>
                  <dd>—</dd>
                  <dt>Teléfono</dt>
                  <dd>—</dd>
                  <dt>Teléfono móvil</dt>
                  <dd>—</dd>
                  <dt>Fax</dt>
                  <dd>—</dd>
                </dl>
              }
              @case ('Correspondencia') {
                @for (disponibilidad of disponibilidadPagador(pestanaPagador()); track disponibilidad.origen) {
                  <p class="alerta alerta-info">{{ disponibilidad.origen }}: {{ disponibilidad.motivo }}</p>
                }
                <dl class="datos">
                  <dt>Destinatario</dt>
                  <dd>—</dd>
                  <dt>Direccion</dt>
                  <dd>—</dd>
                </dl>
              }
            }
            <button type="button" class="btn btn-secundario" (click)="pagadorAbierto.set(false)">
              CERRAR
            </button>
          </div>
        </div>
      }
    }
  `,
  styles: [
    `
      .menu-recibo {
        position: relative;
      }
      .menu-recibo summary {
        list-style: none;
        cursor: pointer;
      }
      .menu-recibo summary::-webkit-details-marker {
        display: none;
      }
      .menu {
        position: absolute;
        right: 0;
        z-index: 20;
        min-width: 14rem;
        background: #fff;
        border: 1px solid #d9d9d9;
        border-radius: 4px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        display: flex;
        flex-direction: column;
      }
      .menu button,
      .menu a {
        text-align: left;
        padding: 0.6rem 1rem;
        background: none;
        border: 0;
        color: #222;
        text-decoration: none;
        cursor: pointer;
        font: inherit;
      }
      .alerta {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        padding: 0.6rem 0.8rem;
        border-radius: 4px;
        margin: 0.75rem 0;
      }
      .alerta-ok {
        background: #e9f7ef;
        color: #1e7b45;
      }
      .alerta-error {
        background: #fdecec;
        color: #a4121c;
      }
    `,
  ],
})
export class ReciboPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly t = TEXTOS_RECIBO;
  readonly numero = input.required<string>();
  readonly recibo = signal<Recibo | null>(null);
  readonly acciones = signal<AccionRecibo[]>([]);
  readonly detalle = signal<ReciboDetalle | null>(null);
  readonly menuAbierto = signal(false);
  readonly mensaje = signal<string | null>(null);
  readonly esError = signal(false);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;
  readonly pestanas = PESTANAS_RECIBO;
  readonly pestana = signal<(typeof PESTANAS_RECIBO)[number]>(this.pestanas[0]);
  readonly pestanasPagador = PESTANAS_PAGADOR;
  readonly pestanaPagador = signal<(typeof PESTANAS_PAGADOR)[number]>(this.pestanasPagador[0]);
  readonly pagadorAbierto = signal(false);

  constructor() {
    effect(() => void this.cargar(this.numero()));
  }

  async cargar(numero: string): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    this.detalle.set(null);
    try {
      const [recibo, acciones] = await Promise.all([
        firstValueFrom(this.repo.recibo(numero)),
        firstValueFrom(this.repo.accionesRecibo(numero)).catch(() => ({ items: [], total: 0 })),
      ]);
      this.recibo.set(recibo);
      this.acciones.set(acciones.items);
    } catch (e) {
      this.error.set((e as Error).message);
    } finally {
      this.cargando.set(false);
    }
  }

  async ejecutar(a: AccionRecibo): Promise<void> {
    this.menuAbierto.set(false);
    this.mensaje.set(null);
    try {
      if (a.codigo === 'VISUALIZAR_DUPLICADO') {
        const d = await firstValueFrom(this.repo.duplicadoRecibo(this.numero()));
        this.descargar(d.nombreFichero, d.tipoMime, d.contenidoBase64);
        this.informar(`${this.t.duplicadoGenerado}: ${d.nombreFichero}`, false);
      } else if (a.codigo === 'DETALLE') {
        this.detalle.set(await firstValueFrom(this.repo.detalleRecibo(this.numero())));
      }
    } catch (e) {
      const err = e as { error?: { detail?: string }; message?: string };
      this.informar(
        err.error?.detail ?? err.message ?? 'No se ha podido completar la acción',
        true,
      );
    }
  }

  disponibilidadPagador(pestana: string) {
    return this.detalle()?.disponibilidadPagador?.filter((dato) => dato.dato === pestana) ?? [];
  }

  private informar(texto: string, error: boolean): void {
    this.mensaje.set(texto);
    this.esError.set(error);
  }

  private descargar(nombre: string, mime: string, base64: string): void {
    if (typeof document === 'undefined' || typeof URL.createObjectURL !== 'function') return;
    const bytes = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
    const url = URL.createObjectURL(new Blob([bytes], { type: mime }));
    const a = document.createElement('a');
    a.href = url;
    a.download = nombre;
    a.click();
    URL.revokeObjectURL(url);
  }
}
