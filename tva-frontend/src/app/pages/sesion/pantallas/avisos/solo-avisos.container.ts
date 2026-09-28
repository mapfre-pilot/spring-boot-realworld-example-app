/** SOLO_AVISOS: la sesión solo puede mostrar avisos. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { PanelResultadoComponent } from '../../../../shared/ui/feedback/panel-resultado.component';

@Component({
  selector: 'app-solo-avisos',
  imports: [PanelResultadoComponent],
  templateUrl: './solo-avisos.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SoloAvisosContainer {}
