/** Equivale a TVA_MigasDePan: pasos de la secuencia con el actual resaltado. */
import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';

import { Pantalla } from '../../core/models/models';

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
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <nav class="migas" aria-label="Pasos">
      @for (paso of pasos(); track paso; let last = $last) {
        <span class="paso" [class.activo]="paso === actual()">{{ etiqueta(paso) }}</span>
        @if (!last) {
          <span class="separador">›</span>
        }
      }
    </nav>
  `,
  styles: `
    .migas {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
      padding: 8px 0;
      font-size: 0.9em;
    }
    .paso {
      color: #666;
    }
    .paso.activo {
      color: #d81e05;
      font-weight: 600;
    }
    .separador {
      color: #bbb;
    }
  `,
})
export class MigasDePanComponent {
  readonly pasos = input.required<Pantalla[]>();
  readonly actual = input.required<Pantalla | null>();
  readonly visibles = computed(() => this.pasos());

  etiqueta(paso: Pantalla): string {
    return ETIQUETAS[paso] ?? paso;
  }
}
