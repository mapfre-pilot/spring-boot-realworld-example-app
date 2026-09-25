/** Equivale a TVA_Cabecera: marca MAPFRE, título, modalidad y usuario. */
import { ChangeDetectionStrategy, Component, inject, input } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatTooltipModule } from '@angular/material/tooltip';

import { AuthService, Modalidad } from '@tva/core';

@Component({
  selector: 'app-cabecera',
  imports: [MatButtonModule, MatIconModule, MatTooltipModule],
  templateUrl: './cabecera.component.html',
  styleUrl: './cabecera.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  host: { class: 'app-cabecera' },
})
export class CabeceraComponent {
  readonly auth = inject(AuthService);
  readonly modalidad = input<Modalidad | null>(null);
}
