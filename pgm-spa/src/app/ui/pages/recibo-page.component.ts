import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { Recibo } from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';

/** /recibos/:numero — detalle de recibo. */
@Component({
  selector: 'pgm-recibo-page',
  imports: [DatePipe, CurrencyPipe, RouterLink, EstadoComponent],
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
        </div>
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
      </section>
    }
  `,
})
export class ReciboPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly numero = input.required<string>();
  readonly recibo = signal<Recibo | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;

  constructor() {
    effect(() => void this.cargar(this.numero()));
  }

  async cargar(numero: string): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    try {
      this.recibo.set(await firstValueFrom(this.repo.recibo(numero)));
    } catch (e) {
      this.error.set((e as Error).message);
    } finally {
      this.cargando.set(false);
    }
  }
}
