/** SISTEMA_CERRADO: la aplicación está cerrada (TVA_APLICACION_CERRADA). */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { PanelResultadoComponent } from '../../../../../shared/ui/feedback/panel-resultado/panel-resultado.component';

@Component({
  selector: 'app-sistema-cerrado',
  imports: [PanelResultadoComponent],
  templateUrl: './sistema-cerrado.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SistemaCerradoContainer {}
