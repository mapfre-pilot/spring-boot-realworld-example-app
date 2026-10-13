import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-informes-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Impresión de informes</h1>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label
            >Tipo de emisión<input formControlName="tipoEmision" maxlength="2"
          /></label>
          <label
            >Año desde<input formControlName="anioDesde" maxlength="4"
          /></label>
          <label
            >Año hasta<input formControlName="anioHasta" maxlength="4"
          /></label>
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
            >Fecha de emisión desde<input
              type="date"
              formControlName="fechaEmisionDesde"
          /></label>
          <label
            >Fecha de emisión hasta<input
              type="date"
              formControlName="fechaEmisionHasta"
          /></label>
          <label
            >Fecha de pago desde<input
              type="date"
              formControlName="fechaPagoDesde"
          /></label>
          <label
            >Fecha de pago hasta<input
              type="date"
              formControlName="fechaPagoHasta"
          /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Revisa los criterios indicados.</p>
        }
        <div class="actions">
          <button type="submit">Generar informe</button>
        </div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
    </section>
  `,
})
export class InformesPageComponent {
  readonly form = new FormGroup({
    tipoEmision: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.maxLength(2)],
    }),
    anioDesde: new FormControl('', {
      nonNullable: true,
      validators: [Validators.pattern(/^\d{4}$/)],
    }),
    anioHasta: new FormControl('', {
      nonNullable: true,
      validators: [Validators.pattern(/^\d{4}$/)],
    }),
    expedienteDesde: new FormControl('', {
      nonNullable: true,
      validators: [Validators.maxLength(10)],
    }),
    expedienteHasta: new FormControl('', {
      nonNullable: true,
      validators: [Validators.maxLength(10)],
    }),
    fechaEmisionDesde: new FormControl('', { nonNullable: true }),
    fechaEmisionHasta: new FormControl('', { nonNullable: true }),
    fechaPagoDesde: new FormControl('', { nonNullable: true }),
    fechaPagoHasta: new FormControl('', { nonNullable: true }),
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.useCases.printInforme(this.form.getRawValue()).subscribe((result) => {
      this.mensaje = `Informe solicitado${result.id ? `: ${result.id}` : '.'}`;
    });
  }
}
