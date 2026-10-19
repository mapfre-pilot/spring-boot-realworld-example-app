import { Component, input, output, signal } from '@angular/core';
import { RAMOS, Ramo } from '../../domain/models/api.models';

export const ETIQUETA_RAMO: Record<Ramo, string> = {
  AUTOS: 'Autos',
  HOGAR: 'Hogar',
  SALUD: 'Salud',
  VIDA: 'Vida',
  DECESOS: 'Decesos',
  AHORRO: 'Ahorro',
  EMPRESAS: 'Empresas',
  OTROS: 'Otros',
};

/** Carrusel de ramos/productos: selecciona el ramo activo para lanzaderas y tarjetas. */
@Component({
  selector: 'pgm-carrusel-ramos',
  template: `
    <div class="carrusel">
      <button class="btn btn-secundario" (click)="desplazar(-1)" aria-label="Anterior">‹</button>
      <div class="pista" [style.transform]="'translateX(-' + inicio() * 124 + 'px)'">
        @for (r of ramos(); track r) {
          <button class="tarjeta" [class.activa]="r === seleccionado()" (click)="seleccionar(r)">
            <span class="icono">{{ iconos[r] }}</span>
            <span>{{ etiquetas[r] }}</span>
          </button>
        }
      </div>
      <button class="btn btn-secundario" (click)="desplazar(1)" aria-label="Siguiente">›</button>
    </div>
  `,
  styles: `
    .carrusel {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      overflow: hidden;
    }
    .pista {
      display: flex;
      gap: 0.5rem;
      transition: transform 0.25s;
    }
    .tarjeta {
      width: 116px;
      height: 72px;
      border: 1px solid var(--pgm-gris-2);
      border-radius: 6px;
      background: #fff;
      cursor: pointer;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 0.25rem;
      font: inherit;
    }
    .tarjeta.activa {
      border-color: var(--pgm-rojo);
      color: var(--pgm-rojo);
      font-weight: 600;
    }
    .icono {
      font-size: 1.3rem;
    }
  `,
})
export class CarruselRamosComponent {
  readonly ramos = input<Ramo[]>(RAMOS);
  readonly seleccionado = input<Ramo | null>(null);
  readonly seleccion = output<Ramo>();
  readonly inicio = signal(0);
  readonly etiquetas = ETIQUETA_RAMO;
  readonly iconos: Record<Ramo, string> = {
    AUTOS: '🚗',
    HOGAR: '🏠',
    SALUD: '🩺',
    VIDA: '🛡',
    DECESOS: '🕊',
    AHORRO: '💶',
    EMPRESAS: '🏢',
    OTROS: '📦',
  };

  seleccionar(r: Ramo): void {
    this.seleccion.emit(r);
  }

  desplazar(d: number): void {
    const max = Math.max(0, this.ramos().length - 4);
    this.inicio.set(Math.min(max, Math.max(0, this.inicio() + d)));
  }
}
