/** CAPTURA_TOMADOR2 — contenedor del formulario de tomador + requisitos (§12.2). */
import { ChangeDetectionStrategy, Component } from '@angular/core';

import { TomadorFormComponent } from './tomador-form.component';
import { TomadorBase } from './tomador-base';

@Component({
  selector: 'app-tomador2',
  imports: [TomadorFormComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './captura-tomador2.container.html',
})
export class CapturaTomador2Container extends TomadorBase {
  readonly cajaId = 'CAPTURA_DATOS_TOMADOR2';
  readonly indiceTomador = 1;
}
