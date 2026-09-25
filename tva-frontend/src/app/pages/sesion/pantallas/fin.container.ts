/** FIN: cierre de la sesión y vuelta a inicio. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { Router } from '@angular/router';

import { SesionStore } from '@tva/core';

@Component({
  selector: 'app-fin',
  imports: [MatCardModule, MatButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-card>
      <mat-card-title>Sesión finalizada</mat-card-title>
      <mat-card-content>La sesión de tarificación ha finalizado correctamente.</mat-card-content>
      <button mat-flat-button color="primary" (click)="volver()">Nueva sesión</button>
    </mat-card>
  `,
})
export class FinContainer {
  private readonly store = inject(SesionStore);
  private readonly router = inject(Router);

  volver(): void {
    this.store.limpiar();
    void this.router.navigate(['/']);
  }
}
