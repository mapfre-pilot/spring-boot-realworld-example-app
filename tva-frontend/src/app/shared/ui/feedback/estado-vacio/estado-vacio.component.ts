/** Estado vacío: icono + texto muted para tablas, catálogos o listas sin datos. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-estado-vacio',
  imports: [MatIconModule],
  templateUrl: './estado-vacio.component.html',
  styleUrl: './estado-vacio.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class EstadoVacioComponent {
  readonly mensaje = input.required<string>();
  readonly icono = input<string>('inbox');
}
