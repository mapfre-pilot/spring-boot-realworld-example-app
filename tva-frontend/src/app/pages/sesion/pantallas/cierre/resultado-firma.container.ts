/** RESULTADO_FIRMA: resultado de la firma y enlace a documentos. */
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';

import { EjecutarAccionUsecase, SesionStore } from '@tva/core';

@Component({
  selector: 'app-resultado-firma',
  imports: [MatCardModule, MatButtonModule],
  templateUrl: './resultado-firma.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ResultadoFirmaContainer {
  private readonly store = inject(SesionStore);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  readonly resultado = computed(() =>
    JSON.stringify(this.store.sesion()?.estado?.['firma'] ?? {}, null, 2)
  );

  finalizar(): void {
    this.ejecutarAccion.execute('siguiente', {}).subscribe();
  }
}
