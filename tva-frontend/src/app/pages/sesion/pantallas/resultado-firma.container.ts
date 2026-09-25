/** RESULTADO_FIRMA: resultado de la firma y enlace a documentos. */
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';

import { SesionStore } from '../../../core/state/sesion.store';

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
  readonly resultado = computed(() =>
    JSON.stringify(this.store.sesion()?.estado?.['firma'] ?? {}, null, 2)
  );

  finalizar(): void {
    this.store.ejecutar('siguiente', {}).subscribe();
  }
}
