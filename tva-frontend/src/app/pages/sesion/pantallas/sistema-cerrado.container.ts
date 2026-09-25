/** SISTEMA_CERRADO: la aplicación está cerrada (TVA_APLICACION_CERRADA). */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-sistema-cerrado',
  imports: [MatCardModule],
  templateUrl: './sistema-cerrado.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SistemaCerradoContainer {}
