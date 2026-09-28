/** SIN_PERFIL: usuario sin perfil TVA. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { PanelResultadoComponent } from '../../../../shared/ui/feedback/panel-resultado.component';

@Component({
  selector: 'app-sin-perfil',
  imports: [PanelResultadoComponent],
  templateUrl: './sin-perfil.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SinPerfilContainer {}
