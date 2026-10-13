import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-variables-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Gestión de variables</h1>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label>Año<input formControlName="anio" maxlength="4" /></label>
          <label
            >Número de expediente<input formControlName="numero" maxlength="10"
          /></label>
          <label
            >Código de variable<input formControlName="codigo" required
          /></label>
          <label>Valor<input formControlName="valor" required /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Indica el año, expediente, código y valor.</p>
        }
        <div class="actions">
          <button type="submit">Guardar variable</button>
          <button type="button" (click)="consultar()">
            Consultar variables
          </button>
        </div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
    </section>
  `,
})
export class VariablesPageComponent {
  readonly form = new FormGroup({
    anio: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.pattern(/^\d{4}$/)],
    }),
    numero: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    codigo: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
    valor: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required],
    }),
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    const value = this.form.getRawValue();
    this.useCases
      .saveVariables(value.anio, value.numero, {
        variables: [{ codigo: value.codigo, valor: value.valor }],
      })
      .subscribe(() => {
        this.mensaje = 'Variable guardada.';
      });
  }

  consultar(): void {
    const { anio, numero } = this.form.getRawValue();
    if (!anio || !numero) return;
    this.useCases.getVariables(anio, numero).subscribe((values) => {
      this.mensaje = `${values.variables.length} variables consultadas.`;
    });
  }
}
