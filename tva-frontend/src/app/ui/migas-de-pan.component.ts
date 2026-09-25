/** Equivale a TVA_MigasDePan: sub-barra con pasos, completados con check, actual en rojo. */
import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

import { Pantalla } from '@tva/core';

const ETIQUETAS: Partial<Record<Pantalla, string>> = {
  [Pantalla.SELECCION_PRODUCTO_AHORRO]: 'Selección producto',
  [Pantalla.SEGUROS_AHORRO]: 'Seguros ahorro',
  [Pantalla.MODALIDAD_CAMPANIA]: 'Modalidad campaña',
  [Pantalla.CAPTURA_DATOS_SOLICITUD]: 'Datos solicitud',
  [Pantalla.CAPTURA_TOMADOR1]: 'Tomador 1',
  [Pantalla.CAPTURA_TOMADOR2]: 'Tomador 2',
  [Pantalla.R2C_CAPTURA]: 'R2C captura',
  [Pantalla.R2C_PRECIOS]: 'R2C precios',
  [Pantalla.RESUMEN_CONTRATACION]: 'Resumen',
  [Pantalla.RESULTADO_FIRMA]: 'Resultado firma',
  [Pantalla.FIN]: 'Fin',
};

@Component({
  selector: 'app-migas-de-pan',
  imports: [MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-migas' },
  template: `
    <nav class="migas" aria-label="Pasos del proceso">
      @for (paso of pasos(); track paso; let last = $last, i = $index) {
        <span
          class="paso"
          [class.actual]="paso === actual()"
          [class.completado]="completado(i)"
          [class.futuro]="futuro(i)">
          @if (completado(i)) {
            <mat-icon class="check" aria-hidden="true">check</mat-icon>
          }
          {{ etiqueta(paso) }}
        </span>
        @if (!last) {
          <span class="separador" aria-hidden="true">›</span>
        }
      }
    </nav>
  `,
  styles: `
    :host {
      display: block;
      background: #fff;
      border-bottom: 1px solid var(--tva-border, #e0e0e0);
    }
    .migas {
      display: flex;
      align-items: center;
      flex-wrap: wrap;
      gap: 6px;
      height: 40px;
      max-width: 1200px;
      margin: 0 auto;
      padding: 0 24px;
      font-size: 13px;
    }
    .paso {
      display: inline-flex;
      align-items: center;
      gap: 2px;
      color: #424242;
    }
    .paso .check {
      font-size: 16px;
      width: 16px;
      height: 16px;
      color: var(--tva-ok, #2e7d32);
    }
    .paso.actual {
      color: var(--tva-primary, #d81e05);
      font-weight: 700;
    }
    .paso.futuro {
      color: #9e9e9e;
    }
    .separador {
      color: #bdbdbd;
    }
    @media (max-width: 900px) {
      .migas {
        padding: 0 12px;
      }
    }
  `,
})
export class MigasDePanComponent {
  readonly pasos = input.required<Pantalla[]>();
  readonly actual = input.required<Pantalla | null>();

  private readonly indiceActual = computed(() =>
    this.pasos().indexOf(this.actual() ?? ('' as Pantalla))
  );

  completado(i: number): boolean {
    const idx = this.indiceActual();
    return idx >= 0 && i < idx;
  }

  futuro(i: number): boolean {
    const idx = this.indiceActual();
    return idx >= 0 && i > idx;
  }

  etiqueta(paso: Pantalla): string {
    return ETIQUETAS[paso] ?? paso;
  }
}
