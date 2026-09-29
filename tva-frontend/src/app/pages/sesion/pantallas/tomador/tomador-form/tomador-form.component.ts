/** Formulario del tomador — presentacional compartido por tomador1 y tomador2 (§12.2). */
import { ChangeDetectionStrategy, Component, input, model, output } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';

import { Aviso, FormulariosTomador, PopupAppian } from '@tva/core';
import { CajaComponent } from '../../../../../shared/ui/contenedores/caja/caja.component';
import {
  CampoSelectComponent,
  Opcion,
} from '../../../../../shared/ui/formularios/campo-select/campo-select.component';
import { CampoTextoComponent } from '../../../../../shared/ui/formularios/campo-texto/campo-texto.component';
import { SeccionComponent } from '../../../../../shared/ui/contenedores/seccion/seccion.component';
import { MATERIAL } from '../../../../../shared/ui/material';

export interface RequisitoTomador {
  etiqueta: string;
  popup: PopupAppian;
  hecho: boolean;
  habilitado: boolean;
}

@Component({
  selector: 'app-tomador-form',
  imports: [
    ...MATERIAL,
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
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

  protected catalogo(nombre: string): Opcion[] {
    return this.catalogos()[nombre] ?? [];
  }
}
