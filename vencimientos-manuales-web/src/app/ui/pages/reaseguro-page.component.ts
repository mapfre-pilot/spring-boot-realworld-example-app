import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-reaseguro-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Gestión de reaseguro</h1>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label>Año<input formControlName="anio" maxlength="4" /></label>
          <label
            >Número de expediente<input formControlName="numero" maxlength="10"
          /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Año y expediente son obligatorios.</p>
        }
        <div class="actions">
          <button type="submit">Solicitar operación</button>
        </div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
    </section>
  `,
})
export class ReaseguroPageComponent {
  readonly form = new FormGroup({
    anio: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    numero: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    const { anio, numero } = this.form.getRawValue();
    this.useCases
      .requestReaseguro(anio, numero)
      .subscribe(() => (this.mensaje = 'Solicitud de reaseguro enviada.'));
  }
}
