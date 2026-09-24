/** SISTEMA_CERRADO: la aplicación está cerrada (TVA_APLICACION_CERRADA). */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-sistema-cerrado',
  imports: [MatCardModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-card>
      <mat-card-title>Sistema cerrado</mat-card-title>
      <mat-card-content>El tarificador está cerrado fuera del horario de campaña.</mat-card-content>
    </mat-card>
  `,
})
export class SistemaCerradoContainer {}
