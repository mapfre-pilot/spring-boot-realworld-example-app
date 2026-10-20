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
        <dl class="datos">
          <dt>Ramo</dt>
          <dd>{{ etiquetas[r.ramo] }}</dd>
          <dt>Importe</dt>
          <dd>
            <strong>{{ r.importe | currency: 'EUR' }}</strong>
          </dd>
          <dt>Emisión</dt>
          <dd>{{ r.fechaEmision | date: 'dd/MM/yyyy' }}</dd>
          <dt>Vencimiento</dt>
          <dd>{{ r.fechaVencimiento | date: 'dd/MM/yyyy' }}</dd>
          <dt>Forma de pago</dt>
          <dd>{{ r.formaPago }}</dd>
          <dt>IBAN</dt>
          <dd>{{ r.ibanEnmascarado ?? '—' }}</dd>
        </dl>
        @if (detalle(); as d) {
          <h2>{{ t.detalle }}</h2>
          <dl class="datos" data-testid="detalle-recibo">
            <dt>Producto</dt>
            <dd>{{ d.producto }}</dd>
            <dt>Riesgo</dt>
            <dd>{{ d.riesgo }}</dd>
            <dt>Método de pago</dt>
            <dd>{{ d.metodoPagoLiteral }}</dd>
            <dt>Pagador</dt>
            <dd>{{ d.pagador }}</dd>
            <dt>Estructura comercial</dt>
            <dd>{{ d.estructuraComercial }}</dd>
            <dt>Cuota</dt>
            <dd>{{ d.cuota | currency: 'EUR' }}</dd>
            <dt>Comisiones</dt>
            <dd>{{ d.comisiones | currency: 'EUR' }}</dd>
            <dt>Gestiones</dt>
            <dd>{{ d.gestiones.join(', ') || '—' }}</dd>
          </dl>
        }
      </section>
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
