import { Component, computed, input, output, signal } from '@angular/core';
import { RAMOS, Ramo } from '../../domain/models/api.models';
import { IconoComponent, NombreIcono } from './icono.component';

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

export const DESCRIPCION_RAMO: Record<Ramo, string> = {
  AUTOS: 'Turismos y motos, flotas, camiones, autobuses y vehículos industriales',
  HOGAR: 'Hogar, comunidades, viajes, animales de compañía',
  SALUD: 'Asistencia sanitaria, reembolso, indemnización',
  VIDA: 'Riesgo, accidentes y solución global',
  DECESOS: 'Decesos y asistencia familiar',
  AHORRO: 'Ahorro, rentas y jubilación',
  EMPRESAS: 'Multirriesgo empresarial y comercios, responsabilidad civil, autónomos y pymes',
  OTROS: 'Agropecuario y otros ramos',
};

export const ICONO_RAMO: Record<Ramo, NombreIcono> = {
  AUTOS: 'autos',
  HOGAR: 'hogar',
  SALUD: 'salud',
  VIDA: 'vida',
  DECESOS: 'decesos',
  AHORRO: 'ahorro',
  EMPRESAS: 'empresas',
  OTROS: 'otros',
};

export interface ContadorRamo {
  polizas: number;
  vencimientos: number;
  presupuestos: number;
}

/**
 * Carrusel de productos por ramo (ficha 360: «Resumen» con contadores y acción Vto./Ppto.)
 * o rejilla de ramos (Nueva producción / Cartera / Prestaciones).
 */
@Component({
  selector: 'pgm-carrusel-ramos',
  imports: [IconoComponent],
  template: `
    @if (vista() === 'rejilla') {
      <div class="rejilla">
        @for (r of ramos(); track r) {
          <button
            type="button"
            class="ramo-grande"
            [class.activa]="r === seleccionado()"
            (click)="seleccion.emit(r)"
          >
            <pgm-icono [nombre]="iconos[r]" [tam]="44" [trazo]="1.3" />
            <strong>{{ etiquetas[r] }}</strong>
            <span>{{ descripciones[r] }}</span>
          </button>
        }
      </div>
    } @else {
      <div class="carrusel">
        <button
          class="flecha"
          type="button"
          (click)="desplazar(-1)"
          [disabled]="inicio() === 0"
          aria-label="Anterior"
        >
          <pgm-icono nombre="izquierda" />
        </button>
        <div class="ventana">
          <div class="pista" [style.transform]="'translateX(-' + inicio() * 212 + 'px)'">
            @for (r of ramos(); track r) {
              <div class="tarjeta" [class.vacia]="!cuenta(r).polizas">
                <button type="button" class="cabeza" (click)="seleccion.emit(r)">
                  <span class="nombre">{{ etiquetas[r] }}</span>
                  <span class="fila">
                    <pgm-icono [nombre]="iconos[r]" [tam]="26" [trazo]="1.4" />
                    <span class="contador">{{ cuenta(r).polizas || '–' }}</span>
                  </span>
                </button>
                <div class="pie">
                  <div class="linea">
                    <span>Vtos.</span><span>{{ cuenta(r).vencimientos || '–' }}</span>
                  </div>
                  <div class="linea">
                    <span>Pptos.</span><span>{{ cuenta(r).presupuestos || '–' }}</span>
                  </div>
                  @if (accionTexto()) {
                    <button type="button" class="btn-enlace accion" (click)="accion.emit(r)">
                      <pgm-icono nombre="mas" [tam]="16" [trazo]="2.4" /> {{ accionTexto() }}
                    </button>
                  }
                </div>
              </div>
            }
          </div>
        </div>
        <button
          class="flecha oscura"
          type="button"
          (click)="desplazar(1)"
          [disabled]="inicio() >= maxInicio()"
          aria-label="Siguiente"
        >
          <pgm-icono nombre="derecha" />
        </button>
      </div>
      <div class="puntos" aria-hidden="true">
        @for (p of paginas(); track p) {
          <span [class.activo]="p === inicio()"></span>
        }
      </div>
    }
  `,
  styles: `
    .rejilla {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 1.5rem;
    }
    .ramo-grande {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.6rem;
      padding: 1.5rem 1.25rem 1.75rem;
      min-height: 170px;
      background: #fff;
      border: 1px solid transparent;
      box-shadow: var(--pgm-sombra);
      cursor: pointer;
      font: inherit;
      color: #6c7b88;
    }
    .ramo-grande strong {
      color: var(--pgm-texto);
      font-size: 1.15rem;
    }
    .ramo-grande span {
      color: var(--pgm-texto-2);
      font-size: 0.88rem;
      text-align: center;
    }
    .ramo-grande:hover,
    .ramo-grande.activa {
      border-color: var(--pgm-rojo);
    }
    .ramo-grande.activa strong {
      color: var(--pgm-rojo);
    }
    .carrusel {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }
    .ventana {
      overflow: hidden;
      flex: 1;
      min-width: 0;
    }
    .pista {
      display: flex;
      gap: 12px;
      transition: transform 0.3s;
    }
    .tarjeta {
      flex: 0 0 200px;
      border: 1px solid var(--pgm-borde);
      box-shadow: var(--pgm-sombra);
      background: #fff;
    }
    .cabeza {
      width: 100%;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.6rem;
      padding: 1rem 0.75rem;
      background: var(--pgm-fondo-franja);
      border: none;
      cursor: pointer;
      font: inherit;
      color: #4a5560;
    }
    .nombre {
      font-weight: 700;
      color: var(--pgm-texto);
    }
    .fila {
      display: flex;
      align-items: center;
      gap: 0.75rem;
    }
    .contador {
      min-width: 68px;
      padding: 0.15rem 0;
      background: #4f5b66;
      color: #fff;
      text-align: center;
      font-weight: 600;
    }
    .tarjeta.vacia .cabeza {
      color: #b5bcc2;
    }
    .tarjeta.vacia .nombre {
      color: #9aa3ab;
    }
    .tarjeta.vacia .contador {
      background: #e3e6e8;
      color: #9aa3ab;
    }
    .pie {
      padding: 0.75rem 1.25rem 0.9rem;
      display: grid;
      gap: 0.3rem;
    }
    .linea {
      display: flex;
      justify-content: space-between;
      color: var(--pgm-texto-2);
      font-size: 0.88rem;
    }
    .accion {
      justify-content: center;
      border-top: 1px solid var(--pgm-borde);
      padding-top: 0.6rem;
      margin-top: 0.3rem;
    }
    .flecha {
      width: 38px;
      height: 38px;
      border-radius: 50%;
      border: none;
      background: #eef0f2;
      color: #9aa3ab;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      flex: 0 0 38px;
    }
    .flecha.oscura:not([disabled]) {
      background: #2f3a44;
      color: #fff;
    }
    .flecha[disabled] {
      cursor: default;
      opacity: 0.6;
    }
    .puntos {
      display: flex;
      justify-content: center;
      gap: 6px;
      margin-top: 0.75rem;
    }
    .puntos span {
      width: 9px;
      height: 9px;
      border-radius: 50%;
      background: #d4d8db;
    }
    .puntos span.activo {
      background: #7c8790;
    }
  `,
})
export class CarruselRamosComponent {
  readonly ramos = input<Ramo[]>(RAMOS);
  readonly seleccionado = input<Ramo | null>(null);
  readonly vista = input<'carrusel' | 'rejilla'>('carrusel');
  readonly contadores = input<Partial<Record<Ramo, ContadorRamo>> | null>(null);
  readonly accionTexto = input('');
  readonly seleccion = output<Ramo>();
  readonly accion = output<Ramo>();
  readonly inicio = signal(0);
  readonly etiquetas = ETIQUETA_RAMO;
  readonly descripciones = DESCRIPCION_RAMO;
  readonly iconos = ICONO_RAMO;
  readonly visibles = 5;
  readonly maxInicio = computed(() => Math.max(0, this.ramos().length - this.visibles));
  readonly paginas = computed(() => Array.from({ length: this.maxInicio() + 1 }, (_, i) => i));

  cuenta(r: Ramo): ContadorRamo {
    return this.contadores()?.[r] ?? { polizas: 0, vencimientos: 0, presupuestos: 0 };
  }

  seleccionar(r: Ramo): void {
    this.seleccion.emit(r);
  }

  desplazar(d: number): void {
    this.inicio.set(Math.min(this.maxInicio(), Math.max(0, this.inicio() + d)));
  }
}
