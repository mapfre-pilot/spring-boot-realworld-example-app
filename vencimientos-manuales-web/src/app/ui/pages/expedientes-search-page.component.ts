import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import {
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { RouterLink } from '@angular/router';
import {
  BusquedaExpedientes,
  PaginaExpedientes,
} from '../../domain/models/api.models';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';

@Component({
  selector: 'vida-expedientes-search-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  template: `
    <section class="page">
      <h1>Búsqueda de expedientes</h1>
      <p>
        Busca por expediente, póliza o persona y consulta los resultados
        paginados.
      </p>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <label
          >Modo de búsqueda
          <select formControlName="modo">
            <option value="expediente">Año y número de expediente</option>
            <option value="poliza">Póliza</option>
            <option value="persona">NIF</option>
          </select>
        </label>
        <div class="form-grid">
          <label
            >Año expediente<input formControlName="anio" maxlength="4"
          /></label>
          <label
            >Número expediente<input formControlName="numero" maxlength="10"
          /></label>
          <label>Ramo<input formControlName="ramo" maxlength="3" /></label>
          <label
            >Año póliza<input formControlName="anioPoliza" maxlength="4"
          /></label>
          <label
            >Número póliza<input formControlName="numeroPoliza" maxlength="10"
          /></label>
          <label
            >Subpóliza<input formControlName="subpoliza" maxlength="4"
          /></label>
          <label
            >Certificado<input formControlName="certificado" maxlength="6"
          /></label>
          <label>NIF<input formControlName="nif" maxlength="10" /></label>
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">
          Completa los criterios obligatorios del modo seleccionado.
        </p>
        }
        <div class="actions">
          <button type="submit">Buscar expedientes</button>
        </div>
      </form>
      @if (resultados) {
      <table>
        <thead>
          <tr>
            <th>Expediente</th>
            <th>Ramo</th>
            <th>Póliza</th>
            <th>Situación</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          @for (expediente of resultados.content; track expediente.numero) {
          <tr>
            <td>{{ expediente.anio }}/{{ expediente.numero }}</td>
            <td>{{ expediente.ramo }}</td>
            <td>{{ expediente.numeroPoliza }}</td>
            <td>{{ expediente.situacion }}</td>
            <td>
              <a
                [routerLink]="[
                  '/expedientes',
                  expediente.anio,
                  expediente.numero
                ]"
                >Detalle</a
              >
            </td>
          </tr>
          }
        </tbody>
      </table>
      <div class="actions">
        <button
          type="button"
          (click)="cambiarPagina(-1)"
          [disabled]="resultados.page === 0"
        >
          Anterior
        </button>
        <span
          >Página {{ resultados.page + 1 }} ·
          {{ resultados.totalElements }} resultados</span
        >
        <button
          type="button"
          (click)="cambiarPagina(1)"
          [disabled]="
            (resultados.page + 1) * resultados.size >= resultados.totalElements
          "
        >
          Siguiente
        </button>
      </div>
      }
    </section>
  `,
})
export class ExpedientesSearchPageComponent {
  readonly form = new FormGroup({
    modo: new FormControl<'expediente' | 'poliza' | 'persona'>('expediente', {
      nonNullable: true,
    }),
    anio: new FormControl('', { nonNullable: true }),
    numero: new FormControl('', { nonNullable: true }),
    ramo: new FormControl('', { nonNullable: true }),
    anioPoliza: new FormControl('', { nonNullable: true }),
    numeroPoliza: new FormControl('', { nonNullable: true }),
    subpoliza: new FormControl('', { nonNullable: true }),
    certificado: new FormControl('', { nonNullable: true }),
    nif: new FormControl('', { nonNullable: true }),
    page: new FormControl(0, { nonNullable: true }),
    size: new FormControl(20, { nonNullable: true }),
  });
  resultados?: PaginaExpedientes;

  constructor(private readonly useCases: VencimientosUseCases) {
    this.form.controls.modo.valueChanges.subscribe(() =>
      this.aplicarValidaciones()
    );
    this.aplicarValidaciones();
  }

  submit(): void {
    this.aplicarValidaciones();
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    this.buscar();
  }

  cambiarPagina(delta: number): void {
    this.form.controls.page.setValue(
      Math.max(0, this.form.controls.page.value + delta)
    );
    this.buscar();
  }

  private buscar(): void {
    const value = this.form.getRawValue();
    const criteria: BusquedaExpedientes = {
      anio: value.anio || undefined,
      numero: value.numero || undefined,
      ramo: value.ramo || undefined,
      anioPoliza: value.anioPoliza || undefined,
      numeroPoliza: value.numeroPoliza || undefined,
      subpoliza: value.subpoliza || undefined,
      certificado: value.certificado || undefined,
      nif: value.nif || undefined,
      page: value.page,
      size: value.size,
    };
    this.useCases
      .searchExpedientes(criteria)
      .subscribe((result) => (this.resultados = result));
  }

  private aplicarValidaciones(): void {
    const { modo, anio, numero, ramo, anioPoliza, numeroPoliza, nif } =
      this.form.controls;
    [anio, numero, ramo, anioPoliza, numeroPoliza, nif].forEach((control) =>
      control.clearValidators()
    );
    if (modo.value === 'expediente') {
      anio.setValidators([Validators.required, Validators.pattern(/^\d{4}$/)]);
      numero.setValidators([Validators.required, Validators.maxLength(10)]);
    } else if (modo.value === 'poliza') {
      ramo.setValidators([Validators.required, Validators.maxLength(3)]);
      anioPoliza.setValidators([
        Validators.required,
        Validators.pattern(/^\d{4}$/),
      ]);
      numeroPoliza.setValidators([
        Validators.required,
        Validators.maxLength(10),
      ]);
    } else {
      nif.setValidators([Validators.required, Validators.maxLength(10)]);
    }
    [anio, numero, ramo, anioPoliza, numeroPoliza, nif].forEach((control) =>
      control.updateValueAndValidity({ emitEvent: false })
    );
  }
}
