/** Lista de datos etiqueta/valor en grid responsive (dl). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';

export interface ItemListaDatos {
  etiqueta: string;
  valor: string | null;
}

@Component({
  selector: 'app-lista-datos',
  imports: [],
  templateUrl: './lista-datos.component.html',

  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ListaDatosComponent {
  readonly items = input.required<ItemListaDatos[]>();
  readonly columnas = input<2 | 3 | 4>(3);
}
