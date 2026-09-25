/** MODALIDAD_CAMPANIA: elección de modalidad de campaña de marketing. */
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatRadioModule } from '@angular/material/radio';

import { SesionStore } from '@tva/core';
import { CajaComponent } from '../../../ui/caja.component';

const OPCIONES = [
  { valor: 'CAMPAÑA', etiqueta: 'Campaña' },
  { valor: 'SIN_CAMPAÑA', etiqueta: 'Sin campaña' },
];

@Component({
  selector: 'app-modalidad-campania',
  imports: [MatRadioModule, ReactiveFormsModule, CajaComponent],
  templateUrl: './modalidad-campania.container.html',
  styleUrl: './modalidad-campania.container.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ModalidadCampaniaContainer implements OnInit {
  private readonly store = inject(SesionStore);
  readonly opciones = OPCIONES;
  readonly form = inject(FormBuilder).nonNullable.group({
    modalidadCampania: ['', Validators.required],
  });

  ngOnInit(): void {
    this.form.valueChanges.subscribe(v => this.store.datosPendientes.set(v));
  }
}
