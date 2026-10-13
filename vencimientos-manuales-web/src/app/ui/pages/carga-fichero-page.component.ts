import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-carga-fichero-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Carga de fichero</h1>
      <p class="error">
        El contrato actual del BFF solo admite el tipo de emisión y no
        transporta contenido binario.
      </p>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <label
          >Tipo de emisión<input formControlName="tipoEmision" maxlength="2"
        /></label>
        @if (form.invalid && form.touched) {
        <p class="error">Indica el tipo de emisión.</p>
        }
        <div class="actions"><button type="submit">Cargar fichero</button></div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
    </section>
  `,
})
export class CargaFicheroPageComponent {
  readonly form = new FormGroup({
    tipoEmision: new FormControl('', {
      nonNullable: true,
      validators: [Validators.required, Validators.maxLength(2)],
    }),
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.useCases.uploadFile(this.form.getRawValue()).subscribe((result) => {
      this.mensaje = `Carga solicitada${
        result.cargaId ? `: ${result.cargaId}` : '.'
      }`;
    });
  }
}
