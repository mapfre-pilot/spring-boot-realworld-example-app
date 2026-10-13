import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-finiquitos-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Emisión de finiquitos</h1>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label>Año<input formControlName="anio" maxlength="4" /></label>
          <label
            >Expediente desde<input
              formControlName="expedienteDesde"
              maxlength="10"
          /></label>
          <label
            >Expediente hasta<input
              formControlName="expedienteHasta"
              maxlength="10"
          /></label>
          <label
            >Fecha de emisión<input type="date" formControlName="fechaEmision"
          /></label>
          <label
            >Tipo de emisión<input formControlName="tipoEmision" maxlength="2"
          /></label>
          <label
            >Lugar de envío<input formControlName="lugarEnvio" maxlength="2"
          /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Completa el año y el rango de expedientes.</p>
        }
        <div class="actions">
          <button type="submit">Emitir finiquito</button>
        </div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
    </section>
  `,
})
export class FiniquitosPageComponent {
  readonly form = new FormGroup({
    anio: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^\d{4}$/)],
    }),
    expedienteDesde: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    expedienteHasta: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    fechaEmision: new FormControl('', { nonNullable: true }),
    tipoEmision: new FormControl('', {
      nonNullable: true,
      validators: [Validators.maxLength(2)],
    }),
    lugarEnvio: new FormControl('', {
      nonNullable: true,
      validators: [Validators.maxLength(2)],
    }),
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.useCases
      .emitFiniquitos(this.form.getRawValue())
      .subscribe((result) => {
        this.mensaje = `Emisión solicitada${
          result.id ? `: ${result.id}` : '.'
        }`;
      });
  }
}
