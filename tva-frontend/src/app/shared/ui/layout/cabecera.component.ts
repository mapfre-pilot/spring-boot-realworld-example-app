/** Equivale a TVA_Cabecera: marca MAPFRE, título, modalidad y usuario. */
import { ChangeDetectionStrategy, Component, inject, input } from '@angular/core';

import { AuthService, Modalidad } from '@tva/core';
import { MATERIAL } from '../material';

@Component({
  selector: 'app-cabecera',
  imports: [...MATERIAL],
  templateUrl: './cabecera.component.html',
  styleUrl: './cabecera.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-cabecera' },
})
export class CabeceraComponent {
  readonly auth = inject(AuthService);
  readonly modalidad = input<Modalidad | null>(null);
}
