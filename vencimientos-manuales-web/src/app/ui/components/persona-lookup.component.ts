import { Component } from '@angular/core';
import { FormControl, ReactiveFormsModule, Validators } from '@angular/forms';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';
import { Persona } from '../../domain/models/api.models';

@Component({
  selector: 'vida-persona-lookup',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <section class="lookup" aria-labelledby="persona-titulo">
      <h2 id="persona-titulo">Buscar persona por NIF</h2>
      <form (ngSubmit)="buscar()">
        <label for="persona-nif">NIF</label>
        <input id="persona-nif" [formControl]="nif" maxlength="10" />
        <button type="submit">Buscar</button>
      </form>
      @if (persona) {
      <p>{{ persona.nombre }} {{ persona.apellidos }} · {{ persona.nif }}</p>
      }
    </section>
  `,
  styles: [
    `
      .lookup {
        border-top: 1px solid #d7dee8;
        margin-top: 1.5rem;
        padding-top: 1rem;
      }
    `,
  ],
})
export class PersonaLookupComponent {
  readonly nif = new FormControl('', {
    nonNullable: true,
    validators: [Validators.required, Validators.maxLength(10)],
  });
  persona?: Persona;

  constructor(private readonly useCases: VencimientosUseCases) {}

  buscar(): void {
    if (this.nif.invalid) {
      this.nif.markAsTouched();
      return;
    }
    this.useCases
      .getPersona(this.nif.value)
      .subscribe((persona) => (this.persona = persona));
  }
}
