import { Component, computed, input } from '@angular/core';
import { RAMOS, Ramo } from '../../domain/models/api.models';
import { LanzaderasRamoComponent } from './lanzaderas-ramo-page.component';

/** /nueva-produccion — pestañas y tarjetas de la interfaz viva PGM_NuevaProduccion. */
@Component({
  selector: 'pgm-nueva-produccion-page',
  imports: [LanzaderasRamoComponent],
  template: `
    <pgm-lanzaderas-ramo
      titulo="Nueva Producción"
      descripcion="Tarificación y emisión de nuevas pólizas por ramo en los aplicativos corporativos."
      pagina="nueva-produccion"
      [ramoInicial]="ramoInicial()"
    />
  `,
})
export class NuevaProduccionPageComponent {
  readonly ramo = input<string>();
  readonly ramoInicial = computed<Ramo | null>(() =>
    RAMOS.includes(this.ramo() as Ramo) ? (this.ramo() as Ramo) : null,
  );
}
