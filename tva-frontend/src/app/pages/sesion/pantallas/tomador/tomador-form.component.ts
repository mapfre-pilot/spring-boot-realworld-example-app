/** Formulario del tomador — presentacional compartido por tomador1 y tomador2 (§12.2). */
import { ChangeDetectionStrategy, Component, input, model, output } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatTooltipModule } from '@angular/material/tooltip';

import { Aviso, FormulariosTomador, PopupAppian } from '@tva/core';
import { CajaComponent } from '../../../ui/caja.component';
import { CampoSelectComponent, Opcion } from '../../../ui/campo-select.component';
import { CampoTextoComponent } from '../../../ui/campo-texto.component';
import { SeccionComponent } from '../../../ui/seccion.component';

export interface RequisitoTomador {
  etiqueta: string;
  popup: PopupAppian;
  hecho: boolean;
  habilitado: boolean;
}

@Component({
  selector: 'app-tomador-form',
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
    MatTooltipModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './tomador-form.component.html',
  styleUrl: './tomador-form.component.scss',
})
export class TomadorFormComponent {
  readonly grupos = input.required<FormulariosTomador>();
  readonly hayRepresentante = model.required<boolean>();
  readonly catalogos = input<Record<string, Opcion[]>>({});
  readonly validez = input<Record<string, boolean>>({});
  readonly expandidaId = input.required<string>();
  readonly avisos = input<Aviso[]>([]);
  readonly cajaId = input.required<string>();
  readonly requisitos = input<RequisitoTomador[]>([]);
  readonly continuar = output<string>();
  readonly requisito = output<RequisitoTomador>();
}
