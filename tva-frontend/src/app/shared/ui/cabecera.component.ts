/** Equivale a TVA_Cabecera: título de la app, modalidad y usuario. */
import { ChangeDetectionStrategy, Component, inject, input } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatToolbarModule } from '@angular/material/toolbar';

import { AuthService } from '../../core/auth/auth.service';
import { Modalidad } from '../../core/models/models';

@Component({
  selector: 'app-cabecera',
  imports: [MatToolbarModule, MatButtonModule, MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-toolbar color="primary">
      <span>Tarificador Vida Ahorro</span>
      @if (modalidad(); as m) {
        <span class="modalidad">{{ m }}</span>
      }
      <span class="spacer"></span>
      <span class="usuario">{{ auth.usuario() }}</span>
      <button mat-icon-button (click)="auth.logout()" aria-label="Cerrar sesión">
        <mat-icon>logout</mat-icon>
      </button>
    </mat-toolbar>
  `,
  styles: `
    .spacer {
      flex: 1;
    }
    .modalidad {
      margin-left: 16px;
      font-size: 0.85em;
      opacity: 0.9;
    }
    .usuario {
      font-size: 0.85em;
      margin-right: 8px;
    }
  `,
})
export class CabeceraComponent {
  readonly auth = inject(AuthService);
  readonly modalidad = input<Modalidad | null>(null);
}
