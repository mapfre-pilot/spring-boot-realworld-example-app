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
  templateUrl: './botonera.component.html',
  styleUrl: './botonera.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-botonera' },
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
