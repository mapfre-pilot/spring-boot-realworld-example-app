import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-bdgi-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Petición BDGI</h1>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label
            >Año ejercicio<input
              type="number"
              formControlName="anioEjercicio"
              min="1900"
              max="2200"
          /></label>
          <label
            >Mes ejercicio<input
              type="number"
              formControlName="mesEjercicio"
              min="1"
              max="12"
          /></label>
          <label
            >Fecha inicial<input type="date" formControlName="fechaInicial"
          /></label>
          <label
            >Fecha final<input type="date" formControlName="fechaFinal"
          /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Completa el ejercicio y el intervalo de fechas.</p>
        }
        <div class="actions"><button type="submit">Solicitar BDGI</button></div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
    </section>
  `,
})
export class BdgiPageComponent {
  readonly form = new FormGroup({
    anioEjercicio: new FormControl<number | null>(null, [
      Validators.required,
      Validators.min(1900),
      Validators.max(2200),
    ]),
    mesEjercicio: new FormControl<number | null>(null, [
      Validators.required,
      Validators.min(1),
      Validators.max(12),
    ]),
    fechaInicial: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    fechaFinal: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    const request = this.form.getRawValue();
    this.useCases
      .requestBdgi({
        anioEjercicio: request.anioEjercicio ?? 0,
        mesEjercicio: request.mesEjercicio ?? 0,
        fechaInicial: request.fechaInicial,
        fechaFinal: request.fechaFinal,
      })
      .subscribe((result) => {
        this.mensaje = `Petición enviada${
          result.solicitudId ? `: ${result.solicitudId}` : '.'
        }`;
      });
  }
}
