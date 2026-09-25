/** R2C_PRECIOS: resultados y acciones recalcular / contratar rentas. */
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';

import { SesionStore } from '@tva/core';

@Component({
  selector: 'app-r2c-precios',
  imports: [MatCardModule, MatButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-card>
      <mat-card-title>Precios de rentas</mat-card-title>
      <mat-card-content>
        <pre>{{ rentasJson() }}</pre>
      </mat-card-content>
    </mat-card>
  `,
  styles: `
    button {
      margin-right: 8px;
    }
  `,
})
export class R2cPreciosContainer {
  private readonly store = inject(SesionStore);
  readonly rentasJson = computed(() =>
    JSON.stringify(this.store.sesion()?.estado?.['rentas'] ?? {}, null, 2)
  );
}
