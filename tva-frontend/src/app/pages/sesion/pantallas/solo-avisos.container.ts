/** SOLO_AVISOS: la sesión solo puede mostrar avisos. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-solo-avisos',
  imports: [MatCardModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-card>
      <mat-card-title>Avisos</mat-card-title>
      <mat-card-content>Consulte los avisos mostrados para continuar.</mat-card-content>
    </mat-card>
  `,
})
export class SoloAvisosContainer {}
