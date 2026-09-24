/** Equivale a TVA_Botonera: botones Anterior / Guardar / Siguiente. */
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';

@Component({
  selector: 'app-botonera',
  imports: [MatButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="botonera">
      @if (mostrarAnterior()) {
        <button mat-stroked-button type="button" (click)="anterior.emit()">Anterior</button>
      }
      <span class="spacer"></span>
      @if (mostrarGuardar()) {
        <button mat-stroked-button type="button" (click)="guardar.emit()">Guardar y volver</button>
      }
      @if (mostrarSiguiente()) {
        <button mat-flat-button color="primary" type="button" (click)="siguiente.emit()">
          {{ textoSiguiente() }}
        </button>
      }
    </div>
  `,
  styles: `
    .botonera {
      display: flex;
      gap: 8px;
      padding: 16px 0;
    }
    .spacer {
      flex: 1;
    }
  `,
})
export class BotoneraComponent {
  readonly mostrarAnterior = input(true);
  readonly mostrarGuardar = input(true);
  readonly mostrarSiguiente = input(true);
  readonly textoSiguiente = input('Siguiente');
  readonly anterior = output<void>();
  readonly guardar = output<void>();
  readonly siguiente = output<void>();
}
