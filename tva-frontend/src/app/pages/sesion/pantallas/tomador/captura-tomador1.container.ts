/** CAPTURA_TOMADOR1 — contenedor del formulario de tomador + requisitos (§12.2). */
import { ChangeDetectionStrategy, Component } from '@angular/core';

import { TomadorFormComponent } from './tomador-form.component';
import { TomadorBase } from './tomador-base';

@Component({
  selector: 'app-tomador1',
  imports: [TomadorFormComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './captura-tomador1.container.html',
})
export class CapturaTomador1Container extends TomadorBase {
  readonly cajaId = 'CAPTURA_DATOS_TOMADOR1';
  readonly indiceTomador = 0;
}
