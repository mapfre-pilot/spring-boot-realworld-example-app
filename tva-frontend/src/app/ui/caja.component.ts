/** Wrapper de caja — equivale a las cajas TVA_Caja_* (tarjeta con título). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatExpansionModule } from '@angular/material/expansion';

@Component({
  selector: 'app-caja',
  imports: [MatExpansionModule],
  templateUrl: './caja.component.html',
  styleUrl: './caja.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CajaComponent {
  readonly titulo = input.required<string>();
  readonly expandida = input(true);
}
