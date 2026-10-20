import { Component, computed, effect, inject, input, output, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Lanzadera, RAMOS, Ramo } from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from './carrusel-ramos.component';
import { IconoComponent } from './icono.component';
import { EstadoComponent } from './estado.component';

/** Nombre de la aplicación de destino tal y como la nombra PGM en Appian (tarjetas por ramo). */
export const ETIQUETA_DESTINO: Record<string, string> = {
  NSE: 'NSE · Nuevo Sistema de Emisión',
  GESALUD: 'Gesalud',
  GESVIDA: 'GESVIDA / WEBVIDA',
  PORTAL_INTERNO: 'Portal Interno',
  SGC30: 'Sistema de gestión comercial 3.0',
  SGO: 'Sistema de Gestión de Operaciones',
  CITRIX: 'VirtualApps (Citrix)',
};

interface Tarjeta {
  destino: string;
  titulo: string;
  enlaces: Lanzadera[];
}

/**
 * Pop-up de accesos del menú superior (N. Producción, Gest. Cartera, Recibos, Prestaciones): replica las tarjetas por ramo
 * de PGM en Appian (pestañas de ramo + tarjetas con enlaces en rojo). Las lanzaderas son enlaces entregados por el BFF.
 */
@Component({
  selector: 'pgm-menu-lanzaderas',
  imports: [RouterLink, IconoComponent, EstadoComponent],
  template: `
    <div class="fondo" (click)="cerrar.emit()" (keydown.escape)="cerrar.emit()" tabindex="-1"></div>
    <section class="popup" role="dialog" aria-modal="true" [attr.aria-label]="titulo()">
      <header>
        <h2>{{ titulo() }}</h2>
        <a [routerLink]="ruta()" class="btn-enlace" (click)="cerrar.emit()"
          >Abrir página completa</a
        >
        <button type="button" class="cerrar" aria-label="Cerrar" (click)="cerrar.emit()">×</button>
      </header>
      <nav class="ramos" aria-label="Ramos">
        @for (r of ramos; track r) {
          <button type="button" [class.activo]="ramo() === r" (click)="ramo.set(r)">
            {{ etiquetas[r] }}
          </button>
        }
      </nav>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
      <div class="tarjetas" data-testid="tarjetas">
        @for (t of tarjetas(); track t.destino) {
          <article class="tarjeta">
            <pgm-icono nombre="documento" [tam]="28" />
            <div>
              <h3>{{ t.titulo }}</h3>
              @for (l of t.enlaces; track l.codigo) {
                @if (l.requiereNuuma && !store.nuuma()) {
                  <span class="enlace bloqueado" [title]="'Requiere NUUMA'">{{ l.nombre }}</span>
                } @else {
                  <a class="enlace" [href]="l.url" target="_blank" rel="noopener">
                    {{ l.nombre }} <pgm-icono nombre="externo" [tam]="14" />
                  </a>
                }
              }
            </div>
          </article>
        } @empty {
          @if (!cargando()) {
            <p class="muted">No hay accesos de {{ etiquetas[ramo()] }} en {{ titulo() }}.</p>
          }
        }
      </div>
    </section>
  `,
  styles: `
    .fondo {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.35);
      z-index: 40;
    }
    .popup {
      position: fixed;
      top: 96px;
      left: 50%;
      transform: translateX(-50%);
      width: min(1100px, 94vw);
      max-height: calc(100vh - 120px);
      overflow: auto;
      background: #fff;
      border-radius: 6px;
      box-shadow: 0 12px 40px rgba(0, 0, 0, 0.25);
      z-index: 41;
    }
    header {
      display: flex;
      align-items: center;
      gap: 1rem;
      padding: 1rem 1.5rem 0.5rem;
    }
    header h2 {
      margin: 0;
      flex: 1;
      font-size: 1.25rem;
    }
    .cerrar {
      border: 0;
      background: none;
      font-size: 1.6rem;
      line-height: 1;
      cursor: pointer;
      color: var(--pgm-texto-2);
    }
    .ramos {
      display: flex;
      border-bottom: 1px solid var(--pgm-borde);
      padding: 0 1rem;
      overflow-x: auto;
    }
    .ramos button {
      border: 0;
      background: none;
      padding: 0.75rem 1.25rem;
      cursor: pointer;
      color: var(--pgm-texto-2);
      border-bottom: 3px solid transparent;
      font-size: 0.95rem;
      white-space: nowrap;
    }
    .ramos button.activo {
      color: var(--pgm-texto);
      font-weight: 600;
      border-bottom-color: var(--pgm-rojo);
    }
    .tarjetas {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 1rem;
      padding: 1.25rem 1.5rem 1.5rem;
    }
    .tarjeta {
      display: flex;
      gap: 1rem;
      padding: 1.25rem;
      border: 1px solid var(--pgm-borde);
      border-radius: 4px;
      box-shadow: 0 2px 6px rgba(0, 0, 0, 0.06);
      color: var(--pgm-texto-2);
    }
    .tarjeta h3 {
      margin: 0 0 0.5rem;
      color: var(--pgm-texto);
      font-size: 1.05rem;
    }
    .enlace {
      display: block;
      color: var(--pgm-rojo);
      text-decoration: none;
      padding: 0.2rem 0;
    }
    .enlace:hover {
      text-decoration: underline;
    }
    .enlace.bloqueado {
      color: var(--pgm-texto-2);
      cursor: not-allowed;
    }
  `,
})
export class MenuLanzaderasComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly store = inject(ContextoStore);
  readonly titulo = input.required<string>();
  readonly ruta = input.required<string>();
  readonly cerrar = output<void>();
  readonly ramos = RAMOS;
  readonly etiquetas = ETIQUETA_RAMO;
  readonly ramo = signal<Ramo>(RAMOS[0]);
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly tarjetas = computed<Tarjeta[]>(() => {
    const porDestino = new Map<string, Lanzadera[]>();
    for (const l of this.lanzaderas()) {
      porDestino.set(l.destino, [...(porDestino.get(l.destino) ?? []), l]);
    }
    return [...porDestino.entries()].map(([destino, enlaces]) => ({
      destino,
      titulo: ETIQUETA_DESTINO[destino] ?? destino,
      enlaces,
    }));
  });

  constructor() {
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
