import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { Cartera } from '../../domain/models/api.models';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-cartera-poliza-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Consulta de cartera de póliza</h1>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label>Ramo<input formControlName="ramo" maxlength="3" /></label>
          <label
            >Año de póliza<input formControlName="anio" maxlength="4"
          /></label>
          <label
            >Número de póliza<input formControlName="numero" maxlength="10"
          /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Completa ramo y claves de póliza.</p>
        }
        <div class="actions">
          <button type="submit">Consultar cartera</button>
        </div>
      </form>
      @if (cartera) {
      <p>
        {{ cartera.modalidad }} · {{ cartera.situacion }} ·
        {{ cartera.numeroPoliza }}
      </p>
      }
    </section>
  `,
})
export class CarteraPolizaPageComponent {
  readonly form = new FormGroup({
    ramo: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    anio: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    numero: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
  });
  cartera?: Cartera;

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    const { ramo, anio, numero } = this.form.getRawValue();
    this.useCases
      .getCartera(ramo, anio, numero)
      .subscribe((result) => (this.cartera = result));
  }
}
