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
  templateUrl: './migas-de-pan.component.html',
  styleUrl: './migas-de-pan.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-migas' },
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
