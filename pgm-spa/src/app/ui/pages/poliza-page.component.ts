import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, effect, inject, input, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { Lanzadera, Poliza, Recibo } from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/** /polizas/:numero — ficha de póliza con recibos y acciones (lanzadera del ramo). */
@Component({
  selector: 'pgm-poliza-page',
  imports: [DatePipe, CurrencyPipe, RouterLink, EstadoComponent, TablaExportableComponent],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
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
          @if (lanzadera(); as l) {
            <a class="btn" [href]="l.url" target="_blank" rel="noopener"
              >↗ Gestionar en {{ l.destino }}</a
            >
          }
        </div>
        <div class="grid grid-2">
          <dl class="datos">
            <dt>Producto</dt>
            <dd>{{ p.producto }}</dd>
            <dt>Riesgo</dt>
            <dd>{{ p.riesgo }}</dd>
            <dt>Efecto</dt>
            <dd>{{ p.fechaEfecto | date: 'dd/MM/yyyy' }}</dd>
            <dt>Vencimiento</dt>
            <dd>{{ p.fechaVencimiento | date: 'dd/MM/yyyy' }}</dd>
          </dl>
          <dl class="datos">
            <dt>Prima anual</dt>
            <dd>{{ p.primaAnual | currency: 'EUR' }}</dd>
            <dt>Forma de pago</dt>
            <dd>{{ p.formaPago }}</dd>
            <dt>Acciones</dt>
            <dd>
              @for (a of p.acciones; track a) {
                <span class="chip">{{ a }}</span
                >&nbsp;
              } @empty {
                —
              }
            </dd>
          </dl>
        </div>
      </section>
      <section class="card">
        <pgm-tabla-exportable
          titulo="Recibos de la póliza"
          [nombreFichero]="'recibos-' + p.numero"
          [columnas]="columnas"
          [filas]="recibos()"
        />
      </section>
    }
  `,
})
export class PolizaPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly numero = input.required<string>();
  readonly poliza = signal<Poliza | null>(null);
  readonly recibos = signal<Recibo[]>([]);
  readonly lanzadera = signal<Lanzadera | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;
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
    try {
      const p = await firstValueFrom(this.repo.poliza(numero));
      this.poliza.set(p);
      const [r, l] = await Promise.all([
        firstValueFrom(this.repo.recibosPoliza(numero)),
        firstValueFrom(this.repo.lanzaderas(p.ramo)),
      ]);
      this.recibos.set(r.items);
      this.lanzadera.set(l.items.find((x) => x.codigo === p.lanzadera) ?? l.items[0] ?? null);
    } catch (e) {
      this.error.set((e as Error).message);
    } finally {
      this.cargando.set(false);
    }
  }
}
