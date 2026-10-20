import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { PrestacionDetalle } from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';

/** /prestaciones/:numero — detalle del expediente de prestación (visible si PGM_CONS_VER_DETALLE_PRESTACIONES). */
@Component({
  selector: 'pgm-prestacion-page',
  imports: [DatePipe, CurrencyPipe, RouterLink, EstadoComponent, IconoComponent],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    @if (restringida(); as msg) {
      <section class="card">
        <div class="alerta alerta-info" data-testid="restringida">
          <pgm-icono nombre="aviso" [tam]="16" /> {{ msg }}
        </div>
        <a class="btn btn-secundario" routerLink="/prestaciones">Volver</a>
      </section>
    }
    @if (detalle(); as d) {
      <section class="card">
        <div class="row">
          <h1>Expediente {{ d.prestacion.numero }} · {{ etiquetas[d.prestacion.ramo] }}</h1>
          <span class="chip">{{ d.prestacion.estado }}</span>
          <span class="spacer"></span>
          <a class="btn btn-secundario" [routerLink]="['/polizas', d.prestacion.polizaNumero]"
            >Póliza {{ d.prestacion.polizaNumero }}</a
          >
          <a class="btn btn-secundario" [routerLink]="['/clientes', d.prestacion.clienteId]"
            >Ficha del cliente</a
          >
        </div>
        <div class="grid grid-2">
          <dl class="datos">
            <dt>Tipo</dt>
            <dd>{{ d.prestacion.tipo }}</dd>
            <dt>Descripción</dt>
            <dd>{{ d.prestacion.descripcion }}</dd>
            <dt>Ocurrencia</dt>
            <dd>{{ d.prestacion.fechaOcurrencia | date: 'dd/MM/yyyy' }}</dd>
            <dt>Apertura</dt>
            <dd>{{ d.prestacion.fechaApertura | date: 'dd/MM/yyyy' }}</dd>
          </dl>
          <dl class="datos">
            <dt>Tramitador</dt>
            <dd>{{ d.prestacion.tramitador }}</dd>
            <dt>Oficina tramitadora</dt>
            <dd>{{ d.oficinaTramitadora }}</dd>
            <dt>Importe estimado</dt>
            <dd>{{ d.importeEstimado | currency: 'EUR' }}</dd>
            <dt>Importe pagado</dt>
            <dd>{{ d.importePagado | currency: 'EUR' }}</dd>
            <dt>Código de ramo</dt>
            <dd>{{ d.codigoRamo }}</dd>
          </dl>
        </div>
        <h2>Hitos</h2>
        <ol data-testid="hitos">
          @for (h of d.hitos; track $index) {
            <li>{{ h }}</li>
          }
        </ol>
      </section>
    }
  `,
  styles: [
    `
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
export class PrestacionPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly numero = input.required<string>();
  readonly detalle = signal<PrestacionDetalle | null>(null);
  readonly restringida = signal<string | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;

  constructor() {
    effect(() => void this.cargar(this.numero()));
  }

  async cargar(numero: string): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    this.restringida.set(null);
    try {
      this.detalle.set(await firstValueFrom(this.repo.detallePrestacion(numero)));
    } catch (e) {
      const err = e as { status?: number; error?: { detail?: string }; message?: string };
      if (err.status === 403) {
        this.restringida.set(err.error?.detail ?? 'Detalle de prestaciones no disponible');
      } else {
        this.error.set(err.error?.detail ?? err.message ?? 'Error al cargar la prestación');
      }
    } finally {
      this.cargando.set(false);
    }
  }
}
