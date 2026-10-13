import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import {
  FormArray,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { ExpedienteMutation } from '../../domain/models/api.models';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';
import { PersonaLookupComponent } from '../components/persona-lookup.component';

@Component({
  selector: 'vida-expediente-management-page',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, PersonaLookupComponent],
  template: `
    <section class="page">
      <h1>Alta y gestión de expediente</h1>
      <p>
        Completa los datos del expediente, el cuadro de coaseguro y la
        información fiscal.
      </p>
      <form [formGroup]="form" (ngSubmit)="submit()">
        <div class="form-grid">
          <label>Año<input formControlName="anio" maxlength="4" /></label>
          <label>Número<input formControlName="numero" maxlength="10" /></label>
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
          <label
            >Situación<input formControlName="situacion" maxlength="2"
          /></label>
          <label
            >Capital (€)<input type="number" formControlName="importeCapital"
          /></label>
          <label
            >Beneficios (€)<input type="number" formControlName="beneficios"
          /></label>
          <label
            >Anticipo (€)<input type="number" formControlName="anticipo"
          /></label>
          <label
            >Intereses pendientes (€)<input
              type="number"
              formControlName="interesesPendientes"
          /></label>
          <label
            >Fecha de efecto<input type="date" formControlName="fechaEfecto"
          /></label>
        </div>
        <h2>Coaseguro (hasta 6 entidades)</h2>
        <div formArrayName="coaseguradoras">
          @for (share of coaseguradoras.controls; track $index; let i = $index)
          {
          <div class="form-grid" [formGroupName]="i">
            <label
              >Coaseguradora {{ i + 1
              }}<input formControlName="codigo" maxlength="7"
            /></label>
            <label
              >Porcentaje<input
                type="number"
                formControlName="porcentaje"
                min="0"
                max="100"
            /></label>
          </div>
          }
        </div>
        @if (form.invalid && form.touched) {
        <p class="error">Revisa los campos obligatorios.</p>
        }
        <div class="actions">
          <button type="submit">Guardar alta</button>
          <button type="button" (click)="modificar()">
            Guardar modificación
          </button>
          <button type="button" (click)="anular()">Anular expediente</button>
          <button type="button" (click)="consultar()">Consultar detalle</button>
          <button type="button" (click)="consultarFiscalidad()">
            Consultar fiscalidad
          </button>
          <button type="button" (click)="consultarCoaseguro()">
            Consultar coaseguro
          </button>
          <button type="button" (click)="guardarCoaseguro()">
            Guardar coaseguro
          </button>
          <button type="button" (click)="calcular()">Calcular</button>
        </div>
      </form>
      <p aria-live="polite">{{ mensaje }}</p>
      <vida-persona-lookup />
    </section>
  `,
})
export class ExpedienteManagementPageComponent {
  readonly coaseguradoras = new FormArray(
    Array.from(
      { length: 6 },
      () =>
        new FormGroup({
          codigo: new FormControl('', {
            nonNullable: true,
            validators: [Validators.maxLength(7)],
          }),
          porcentaje: new FormControl<number | null>(null, [
            Validators.min(0),
            Validators.max(100),
          ]),
        })
    )
  );
  readonly form: FormGroup = new FormGroup({
    anio: new FormControl('', [
      Validators.required,
      Validators.pattern(/^\d{4}$/),
    ]),
    numero: new FormControl('', [
      Validators.required,
      Validators.maxLength(10),
    ]),
    ramo: new FormControl(''),
    anioPoliza: new FormControl(''),
    numeroPoliza: new FormControl(''),
    subpoliza: new FormControl(''),
    certificado: new FormControl(''),
    nif: new FormControl(''),
    situacion: new FormControl(''),
    importeCapital: new FormControl<number | null>(null),
    beneficios: new FormControl<number | null>(null),
    anticipo: new FormControl<number | null>(null),
    interesesPendientes: new FormControl<number | null>(null),
    fechaEfecto: new FormControl(''),
    coaseguradoras: this.coaseguradoras,
  });
  mensaje = '';

  constructor(private readonly useCases: VencimientosUseCases) {}

  submit(): void {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;
    const body = this.mutation();
    this.useCases
      .createExpediente(body)
      .subscribe(() => (this.mensaje = 'Alta realizada.'));
  }

  modificar(): void {
    if (this.form.invalid) return;
    const { anio, numero } = this.form.getRawValue();
    this.useCases
      .updateExpediente(anio, numero, this.mutation())
      .subscribe(() => {
        this.mensaje = 'Expediente modificado.';
      });
  }

  anular(): void {
    const { anio, numero } = this.form.getRawValue();
    if (!anio || !numero) return;
    this.useCases
      .annulExpediente(anio, numero)
      .subscribe(() => (this.mensaje = 'Anulación solicitada.'));
  }

  consultar(): void {
    const { anio, numero } = this.form.getRawValue();
    if (!anio || !numero) return;
    this.useCases.getExpediente(anio, numero).subscribe((expediente) => {
      this.form.patchValue(expediente);
      this.mensaje = 'Expediente consultado.';
    });
  }

  consultarFiscalidad(): void {
    const { anio, numero } = this.form.getRawValue();
    if (!anio || !numero) return;
    this.useCases.getFiscalidad(anio, numero).subscribe((datos) => {
      this.mensaje = `Datos fiscales consultados para ${
        datos.nif ?? 'el expediente'
      }.`;
    });
  }

  consultarCoaseguro(): void {
    const { anio, numero } = this.form.getRawValue();
    if (!anio || !numero) return;
    this.useCases.getCoaseguro(anio, numero).subscribe((result) => {
      this.coaseguradoras.controls.forEach((control, index) => {
        control.patchValue(
          result.coaseguradoras[index] ?? { codigo: '', porcentaje: null }
        );
      });
      this.mensaje = 'Cuadro de coaseguro consultado.';
    });
  }

  guardarCoaseguro(): void {
    const { anio, numero } = this.form.getRawValue();
    if (!anio || !numero) return;
    const coaseguradoras = this.shares();
    const hasIncompleteRow = this.coaseguradoras
      .getRawValue()
      .some(
        (item) =>
          Boolean(item.codigo) !==
          (item.porcentaje !== null && item.porcentaje !== undefined)
      );
    const porcentajeTotal = coaseguradoras.reduce(
      (total, item) => total + item.porcentaje,
      0
    );
    if (
      hasIncompleteRow ||
      coaseguradoras.length < 1 ||
      coaseguradoras.length > 6 ||
      Math.abs(porcentajeTotal - 100) > 0.0001
    ) {
      this.mensaje =
        'El coaseguro debe incluir hasta 6 entidades y sumar 100%.';
      return;
    }
    this.useCases
      .saveCoaseguro(anio, numero, { coaseguradoras })
      .subscribe(() => (this.mensaje = 'Cuadro de coaseguro guardado.'));
  }

  calcular(): void {
    const value = this.form.getRawValue();
    this.useCases
      .calculateLiquidation({
        capital: { importe: Number(value.importeCapital || 0) },
        prima: { importe: 0 },
        complementario: { importe: 0 },
        importeCapital: Number(value.importeCapital || 0),
        beneficios: Number(value.beneficios || 0),
        anticipo: Number(value.anticipo || 0),
        interesesPendientes: Number(value.interesesPendientes || 0),
        coaseguradoras: this.shares(),
      })
      .subscribe((result) => {
        this.mensaje = `Cálculo recibido del BFF. Líquido: ${result.liquidoCapital}`;
      });
  }

  private mutation(): ExpedienteMutation {
    const value = this.form.getRawValue();
    return {
      ...value,
      coaseguradoras: this.shares(),
    } as ExpedienteMutation;
  }

  private shares() {
    return this.coaseguradoras
      .getRawValue()
      .filter((item) => item.codigo && item.porcentaje !== null)
      .map((item) => ({
        codigo: item.codigo,
        porcentaje: Number(item.porcentaje),
      }));
  }
}
