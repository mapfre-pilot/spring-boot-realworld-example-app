/** Encabezado estándar de pantalla: título, subtítulo opcional y contenido extra (chips). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-encabezado-pantalla',
  imports: [],
  templateUrl: './encabezado-pantalla.component.html',

  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EncabezadoPantallaComponent {
  readonly titulo = input.required<string>();
  readonly subtitulo = input<string | undefined>(undefined);
}
