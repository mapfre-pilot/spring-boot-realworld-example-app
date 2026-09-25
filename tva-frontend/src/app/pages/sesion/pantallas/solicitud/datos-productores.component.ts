/** Sección Productores (caja DATOS_PRODUCTORES) — presentacional (§12.4.4). */
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatCheckboxModule } from '@angular/material/checkbox';

import { Aviso, FormulariosSolicitud } from '@tva/core';
import { CampoTextoComponent } from '../../../../ui/campo-texto.component';
import { SeccionComponent } from '../../../../ui/seccion.component';

@Component({
  selector: 'app-datos-productores',
  imports: [ReactiveFormsModule, SeccionComponent, CampoTextoComponent, MatCheckboxModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './datos-productores.component.html',
})
export class DatosProductoresComponent {
  readonly form = input.required<FormulariosSolicitud['productores']>();
  readonly valida = input(false);
  readonly expandida = input(false);
  readonly avisos = input<Aviso[]>([]);
  readonly continuar = output<void>();
}
