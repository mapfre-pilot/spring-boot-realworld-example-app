import { Component, computed, effect, inject, input, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Lanzadera, RAMOS, Ramo } from '../../domain/models/api.models';
import { CarruselRamosComponent, ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';

/**
 * Página genérica "por ramo" (Gestión de cartera, Prestaciones, Nueva producción): carrusel de ramos +
 * lanzaderas a los aplicativos corporativos del ramo (NSE, GESALUD, GESVIDA, Portal Interno, Citrix…).
 * Las lanzaderas son enlaces entregados por el BFF, no integraciones.
 */
@Component({
  selector: 'pgm-lanzaderas-ramo',
  imports: [CarruselRamosComponent, EstadoComponent],
  template: `
    <section class="card">
      <h1>{{ titulo() }}</h1>
      <p class="muted">{{ descripcion() }}</p>
      <pgm-carrusel-ramos [seleccionado]="ramo()" (seleccion)="ramo.set($event)" />
    </section>
    <section class="card">
      <h2>{{ etiquetas[ramo()] }}</h2>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
      <div class="grid grid-3">
        @for (l of visibles(); track l.codigo) {
          <article class="card">
            <div class="row">
              <strong>{{ l.nombre }}</strong
              ><span class="spacer"></span><span class="chip">{{ l.destino }}</span>
            </div>
            @if (l.requiereNuuma && !store.nuuma()) {
              <p class="alerta">
                Requiere estructura comercial (NUUMA). Tu usuario no tiene NUUMA asignado.
              </p>
            } @else {
              <a class="btn" [href]="l.url" target="_blank" rel="noopener"
                >Abrir {{ l.destino }} ↗</a
              >
            }
          </article>
        } @empty {
          @if (!cargando()) {
            <div class="vacio">
              No hay lanzaderas de {{ etiquetas[ramo()] }} para {{ titulo() }}
            </div>
          }
        }
      </div>
    </section>
  `,
})
export class LanzaderasRamoComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly store = inject(ContextoStore);
  readonly titulo = input.required<string>();
  readonly descripcion = input('');
  readonly ramoInicial = input<Ramo | null>(null);
  readonly ramo = signal<Ramo>(RAMOS[0]);
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly etiquetas = ETIQUETA_RAMO;
  readonly visibles = computed(() => this.lanzaderas());

  constructor() {
    effect(() => {
      const r = this.ramoInicial();
      if (r) this.ramo.set(r);
    });
    effect(() => void this.cargar(this.ramo()));
  }

  async cargar(ramo: Ramo): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    try {
      this.lanzaderas.set((await firstValueFrom(this.repo.lanzaderas(ramo))).items);
    } catch (e) {
      this.error.set((e as Error).message);
      this.lanzaderas.set([]);
    } finally {
      this.cargando.set(false);
    }
  }
}

@Component({
  selector: 'pgm-gestion-cartera-page',
  imports: [LanzaderasRamoComponent],
  template: `<pgm-lanzaderas-ramo
    titulo="Gestión de cartera"
    descripcion="Suplementos, anulaciones, rehabilitaciones y consultas de cartera por ramo."
  />`,
})
export class GestionCarteraPageComponent {}

@Component({
  selector: 'pgm-prestaciones-page',
  imports: [LanzaderasRamoComponent],
  template: `<pgm-lanzaderas-ramo
    titulo="Prestaciones"
    descripcion="Apertura y seguimiento de siniestros y prestaciones por ramo."
  />`,
})
export class PrestacionesPageComponent {}
