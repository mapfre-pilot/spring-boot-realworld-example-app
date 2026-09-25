/** Equivale a TVA_Cabecera: marca MAPFRE, título, modalidad y usuario. */
import { ChangeDetectionStrategy, Component, inject, input } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';

import { AuthService, Modalidad } from '@tva/core';

@Component({
  selector: 'app-cabecera',
  imports: [MatButtonModule, MatIconModule, MatTooltipModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-cabecera' },
  template: `
    <header class="cabecera">
      <span class="marca">MAPFRE</span>
      <span class="divider" aria-hidden="true"></span>
      <span class="titulo">Tarificador Vida Ahorro</span>
      @if (modalidad(); as m) {
        <span class="chip-modalidad">{{ m }}</span>
      }
      <span class="spacer"></span>
      <span class="usuario">{{ auth.usuario() }}</span>
      <button
        mat-icon-button
        (click)="auth.logout()"
        aria-label="Cerrar sesión"
        matTooltip="Cerrar sesión">
        <mat-icon>logout</mat-icon>
      </button>
    </header>
  `,
  styles: `
    .cabecera {
      display: flex;
      align-items: center;
      height: 56px;
      padding: 0 24px;
      background: var(--tva-primary, #d81e05);
      color: #fff;
    }
    .marca {
      font-weight: 700;
      letter-spacing: 2px;
      font-size: 16px;
    }
    .divider {
      width: 1px;
      height: 22px;
      background: rgb(255 255 255 / 50%);
      margin: 0 14px;
    }
    .titulo {
      font-size: 15px;
      font-weight: 500;
    }
    .chip-modalidad {
      margin-left: 14px;
      padding: 2px 10px;
      border: 1px solid rgb(255 255 255 / 80%);
      border-radius: 12px;
      font-size: 12px;
      font-weight: 600;
    }
    .spacer {
      flex: 1;
    }
    .usuario {
      font-size: 13px;
      margin-right: 4px;
    }
    button {
      color: #fff;
    }
  `,
})
export class CabeceraComponent {
  readonly auth = inject(AuthService);
  readonly modalidad = input<Modalidad | null>(null);
}
