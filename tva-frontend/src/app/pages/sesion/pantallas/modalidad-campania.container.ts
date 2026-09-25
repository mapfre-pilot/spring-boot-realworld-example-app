/** MODALIDAD_CAMPANIA: elección de modalidad de campaña de marketing. */
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatRadioModule } from '@angular/material/radio';

import { SesionStore } from '../../../core/state/sesion.store';
import { CajaComponent } from '../../../shared/ui/caja.component';

const OPCIONES = [
  { valor: 'CAMPAÑA', etiqueta: 'Campaña' },
  { valor: 'SIN_CAMPAÑA', etiqueta: 'Sin campaña' },
];

@Component({
  selector: 'app-modalidad-campania',
  imports: [MatRadioModule, ReactiveFormsModule, CajaComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Modalidad de campaña">
      <form [formGroup]="form">
        <mat-radio-group formControlName="modalidadCampania">
          @for (op of opciones; track op.valor) {
            <mat-radio-button [value]="op.valor">{{ op.etiqueta }}</mat-radio-button>
          }
        </mat-radio-group>
      </form>
    </app-caja>
  `,
  styles: `
    mat-radio-button {
      display: block;
      margin: 4px 0;
    }
  `,
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
