/** RESULTADO_FIRMA: resultado de la firma y enlace a documentos. */
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';

import { EjecutarAccionUsecase, SesionStore } from '@tva/core';

@Component({
  selector: 'app-resultado-firma',
  imports: [MatCardModule, MatButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-card>
      <mat-card-title>Resultado de la firma</mat-card-title>
      <mat-card-content>
        <pre>{{ resultado() }}</pre>
      </mat-card-content>
      <button mat-flat-button color="primary" (click)="finalizar()">Finalizar</button>
    </mat-card>
  `,
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
