/** Botonera data-driven — port de TVA_Botonera (§12.4.3). */
import { ChangeDetectionStrategy, Component, inject, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';

import { Boton } from '@tva/core';
import { ConfirmDialogComponent } from './confirm-dialog.component';

@Component({
  selector: 'app-botonera',
  imports: [MatButtonModule, MatDialogModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="botonera">
      @for (b of visibles(); track b.id) {
        @if (b.id === 'cancelar') {
          <button mat-button type="button" class="link" (click)="emitir(b)">{{ b.label }}</button>
        } @else if (b.id === 'administracion') {
          <button mat-stroked-button type="button" class="centro" (click)="emitir(b)">
            {{ b.label }}
          </button>
        } @else {
          <button
            mat-flat-button
            color="primary"
            type="button"
            [disabled]="b.disabled"
            (click)="emitir(b)">
            {{ b.label }}
          </button>
        }
      }
    </div>
  `,
  styles: `
    .botonera {
      display: flex;
      gap: 8px;
      padding: 16px 0;
      align-items: center;
      flex-wrap: wrap;
    }
    .link {
      color: #d81e05;
    }
    .centro {
      margin-left: auto;
      margin-right: auto;
    }
    button:last-child {
      margin-left: auto;
    }
  `,
})
export class BotoneraComponent {
  readonly botones = input.required<Boton[]>();
  readonly accion = output<string>();
  private readonly dialog = inject(MatDialog);

  visibles(): Boton[] {
    return this.botones().filter(b => b.visible);
  }

  emitir(b: Boton): void {
    if (b.confirm) {
      const ref = this.dialog.open(ConfirmDialogComponent, { data: b.confirm });
      ref.afterClosed().subscribe(ok => {
        if (ok) this.accion.emit(b.id);
      });
    } else {
      this.accion.emit(b.id);
    }
  }
}
