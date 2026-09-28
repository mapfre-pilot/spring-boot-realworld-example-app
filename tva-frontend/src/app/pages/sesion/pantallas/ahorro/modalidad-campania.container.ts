/** MODALIDAD_CAMPANIA: elección de modalidad de campaña de marketing. */
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatRadioModule } from '@angular/material/radio';

import { SesionStore } from '@tva/core';
import { EncabezadoPantallaComponent } from '../../../../shared/ui/layout/encabezado-pantalla.component';
import { CajaComponent } from '../../../../shared/ui/contenedores/caja.component';
import { OPCIONES } from './modalidad-campania.const';

@Component({
  selector: 'app-modalidad-campania',
  imports: [EncabezadoPantallaComponent, MatRadioModule, ReactiveFormsModule, CajaComponent],
  templateUrl: './modalidad-campania.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ModalidadCampaniaContainer implements OnInit {
  private readonly store = inject(SesionStore);
  protected readonly opciones = OPCIONES;
  readonly form = inject(FormBuilder).nonNullable.group({
    modalidadCampania: ['', Validators.required],
  });

  ngOnInit(): void {
    this.form.valueChanges.subscribe(v => this.store.datosPendientes.set(v));
  }
}
