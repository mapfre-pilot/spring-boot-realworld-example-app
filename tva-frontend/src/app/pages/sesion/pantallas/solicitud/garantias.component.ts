/** Sección Garantías (checkboxes con obligatorias) — presentacional (§12.4.4). */
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatCheckboxModule } from '@angular/material/checkbox';

import { Aviso } from '@tva/core';
import { SeccionComponent } from '../../../../ui/seccion.component';

export interface Garantia {
  codigo: string;
  descripcion: string;
  obligatoria: boolean;
  seleccionada?: boolean;
}

@Component({
  selector: 'app-garantias',
  imports: [SeccionComponent, MatCheckboxModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './garantias.component.html',
})
export class GarantiasComponent {
  readonly garantias = input.required<Garantia[]>();
  readonly valida = input(false);
  readonly expandida = input(false);
  readonly avisos = input<Aviso[]>([]);
  readonly continuar = output<void>();
  readonly garantiaCambiada = output<{ i: number; sel: boolean }>();
}
