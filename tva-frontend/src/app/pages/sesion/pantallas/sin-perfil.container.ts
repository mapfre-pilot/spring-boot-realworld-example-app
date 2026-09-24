/** SIN_PERFIL: usuario sin perfil TVA. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-sin-perfil',
  imports: [MatCardModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-card>
      <mat-card-title>Sin perfil</mat-card-title>
      <mat-card-content>Su usuario no dispone de perfil para usar el tarificador.</mat-card-content>
    </mat-card>
  `,
})
export class SinPerfilContainer {}
