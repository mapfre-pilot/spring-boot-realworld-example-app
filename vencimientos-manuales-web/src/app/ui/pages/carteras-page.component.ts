import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { PaginaCarteras } from '../../domain/models/api.models';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-carteras-page',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="page">
      <h1>Carteras</h1>
      <p class="provisional">
        Consulta provisional pendiente de confirmar el contrato de VT03/VT05.
      </p>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label
            >Página<input type="number" formControlName="page" min="0"
          /></label>
          <label
            >Tamaño<input
              type="number"
              formControlName="size"
              min="1"
              max="100"
          /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Indica página y tamaño válidos.</p>
        }
        <div class="actions">
          <button type="submit">Consultar carteras</button>
        </div>
      </form>
      @if (resultados) {
      <ul>
        @for (cartera of resultados.content; track cartera.numeroPoliza) {
        <li>
          {{ cartera.ramo }} · {{ cartera.anioPoliza }}/{{
            cartera.numeroPoliza
          }}
          · {{ cartera.situacion }}
        </li>
        }
      </ul>
      }
    </section>
  `,
  styles: [
    `
      .provisional {
        color: #765400;
      }
    `,
  ],
})
export class CarterasPageComponent {
  readonly form = new FormGroup({
    page: new FormControl<number | null>(null, [
      Validators.required,
      Validators.min(0),
    ]),
    size: new FormControl<number | null>(null, [
      Validators.required,
      Validators.min(1),
      Validators.max(100),
    ]),
  });
  resultados?: PaginaCarteras;

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    const { page, size } = this.form.getRawValue();
    this.useCases
      .listCarteras(page ?? 0, size ?? 20)
      .subscribe((result) => (this.resultados = result));
  }
}
