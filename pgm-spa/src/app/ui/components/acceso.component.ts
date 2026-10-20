import { Component, computed, input, output } from '@angular/core';
import { Lanzadera } from '../../domain/models/api.models';
import { IconoComponent } from './icono.component';

/** Tarjeta de acceso directo a una aplicación corporativa (lanzadera entregada por el BFF; PGM solo enlaza). */
@Component({
  selector: 'pgm-acceso',
  imports: [IconoComponent],
  template: `
    <article class="acceso">
      <span class="sigla">{{ sigla() }}</span>
      <div>
        <h3>{{ l().nombre }}</h3>
        <p>Aplicación externa</p>
        @if (bloqueado()) {
          <span class="chip chip-aviso">Requiere estructura comercial (NUUMA)</span>
        } @else {
          <a [href]="l().url" target="_blank" rel="noopener" (click)="abierto.emit(l())"
            >Abrir {{ destino() }} <pgm-icono nombre="externo" [tam]="15" [trazo]="2.2"
          /></a>
        }
      </div>
    </article>
  `,
})
export class AccesoComponent {
  readonly l = input.required<Lanzadera>();
  readonly bloqueado = input(false);
  readonly abierto = output<Lanzadera>();
  readonly sigla = computed(() =>
    this.l()
      .destino.split(/[_\s-]/)[0]
      .replace(/\d+$/, '')
      .slice(0, 7),
  );
  readonly destino = computed(() => this.l().destino.replace(/_/g, ' '));
}
