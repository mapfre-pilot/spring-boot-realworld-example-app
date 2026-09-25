/** Campo de solo lectura (label + valor) para resúmenes — equivale a MU_ReadOnlyText. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

@Component({
  selector: 'app-campo-lectura',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './campo-lectura.component.html',
  styleUrl: './campo-lectura.component.scss',
})
export class CampoLecturaComponent {
  readonly etiqueta = input.required<string>();
  readonly valor = input<unknown>('');
}
