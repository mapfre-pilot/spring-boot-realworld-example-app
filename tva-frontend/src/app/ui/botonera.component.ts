/** Botonera data-driven — port de TVA_Botonera (§12.4.3). Barra fija inferior. */
import { ChangeDetectionStrategy, Component, inject, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatTooltipModule } from '@angular/material/tooltip';

import { Boton } from '@tva/core';
import { ConfirmDialogComponent } from './confirm-dialog.component';

const IZQUIERDA = new Set(['cancelar', 'administracion']);
const STROKED = new Set(['atras', 'administracion', 'guardar-y-volver', 'volver', 'recalcular']);

@Component({
  selector: 'app-botonera',
  imports: [MatButtonModule, MatDialogModule, MatTooltipModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-botonera' },
  template: `
    <footer class="botonera">
      <div class="contenido">
        <div class="grupo">
          @for (b of grupoIzquierdo(); track b.id) {
            @if (b.id === 'cancelar') {
              <button
                mat-button
                type="button"
                class="link"
                [matTooltip]="tooltip(b)"
                (click)="emitir(b)">
                {{ b.label }}
              </button>
            } @else {
              <button
                mat-stroked-button
                type="button"
                [disabled]="b.disabled"
                [matTooltip]="tooltip(b)"
                (click)="emitir(b)">
                {{ b.label }}
              </button>
            }
          }
        </div>
        <div class="grupo derecha">
          @for (b of grupoDerecho(); track b.id) {
            @if (stroked(b)) {
              <button
                mat-stroked-button
                type="button"
                [disabled]="b.disabled"
                [matTooltip]="tooltip(b)"
                (click)="emitir(b)">
                {{ b.label }}
              </button>
            } @else {
              <button
                mat-flat-button
                color="primary"
                type="button"
                [disabled]="b.disabled"
                [matTooltip]="tooltip(b)"
                (click)="emitir(b)">
                {{ b.label }}
              </button>
            }
          }
        </div>
      </div>
    </footer>
  `,
  styles: `
    :host {
      display: block;
    }
    .botonera {
      position: fixed;
      left: 0;
      right: 0;
      bottom: 0;
      height: 64px;
      background: #fff;
      border-top: 1px solid var(--tva-border, #e0e0e0);
      box-shadow: 0 -2px 6px rgb(0 0 0 / 8%);
      z-index: 100;
    }
    .contenido {
      display: flex;
      align-items: center;
      justify-content: space-between;
      max-width: 1200px;
      height: 100%;
      margin: 0 auto;
      padding: 0 24px;
      gap: 16px;
    }
    .grupo {
      display: flex;
      align-items: center;
      gap: 8px;
      flex-wrap: wrap;
    }
    .grupo.derecha {
      justify-content: flex-end;
    }
    .link {
      color: var(--tva-primary, #d81e05);
    }
    @media (max-width: 900px) {
      .contenido {
        padding: 0 12px;
      }
    }
  `,
})
export class BotoneraComponent {
  readonly botones = input.required<Boton[]>();
  readonly accion = output<string>();
  private readonly dialog = inject(MatDialog);

  grupoIzquierdo(): Boton[] {
    return this.botones().filter(b => b.visible && IZQUIERDA.has(b.id));
  }

  grupoDerecho(): Boton[] {
    return this.botones().filter(b => b.visible && !IZQUIERDA.has(b.id));
  }

  stroked(b: Boton): boolean {
    return STROKED.has(b.id);
  }

  tooltip(b: Boton): string {
    return b.disabled ? (b.tooltip ?? 'Acción no disponible') : '';
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
