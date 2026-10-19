import { Component, computed, inject, input } from '@angular/core';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { RAMOS, Ramo, Visibilidad } from '../../domain/models/api.models';
import { LanzaderasRamoComponent } from './lanzaderas-ramo-page.component';

/** /nueva-produccion — contratación por ramo; Salud se tarifica dentro de PGM desde la ficha del cliente (Vto./Ppto.). */
@Component({
  selector: 'pgm-nueva-produccion-page',
  imports: [LanzaderasRamoComponent],
  template: `
    <pgm-lanzaderas-ramo titulo="Nueva producción" descripcion="Tarificación y emisión de nuevas pólizas por ramo en los aplicativos corporativos." [ramoInicial]="ramoInicial()" />
    @if (store.puede(V.TARIFICACION_SALUD)) {
      <section class="card">
        <h2>Tarificación Salud integrada</h2>
        <p>La tarificación de Salud está disponible dentro de PGM desde la ficha del cliente (botón <strong>Vto. / Ppto.</strong>): busca el cliente en <a href="/inicio">Inicio</a> y lanza el diálogo multipaso.</p>
      </section>
    }
  `,
})
export class NuevaProduccionPageComponent {
  readonly store = inject(ContextoStore);
  readonly V = Visibilidad;
  readonly ramo = input<string>();
  readonly ramoInicial = computed<Ramo | null>(() => (RAMOS.includes(this.ramo() as Ramo) ? (this.ramo() as Ramo) : null));
}
