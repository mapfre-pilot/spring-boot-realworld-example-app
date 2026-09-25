/** CAPTURA_TOMADOR2 — misma estructura que Tomador 1 con caja CAPTURA_DATOS_TOMADOR2. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';

import { CajaComponent } from '../../../shared/ui/caja.component';
import { CampoSelectComponent } from '../../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../../shared/ui/campo-texto.component';
import { SeccionComponent } from '../../../shared/ui/seccion.component';
import { TOMADOR_STYLES, TOMADOR_TEMPLATE } from './captura-tomador1.container';
import { TomadorBase } from './tomador-base';

@Component({
  selector: 'app-tomador2',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    MatCheckboxModule,
    MatSlideToggleModule,
    MatButtonModule,
    MatIconModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: TOMADOR_TEMPLATE,
  styles: TOMADOR_STYLES,
})
export class CapturaTomador2Container extends TomadorBase {
  readonly cajaId = 'CAPTURA_DATOS_TOMADOR2';
  readonly indiceTomador = 1;
}
