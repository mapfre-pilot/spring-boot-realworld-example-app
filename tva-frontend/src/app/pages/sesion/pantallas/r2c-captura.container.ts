/** R2C_CAPTURA: captura de datos de la renta. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import { SesionStore } from '../../../core/state/sesion.store';
import { esDocumentoIdentidadValido } from '../../../core/validaciones/documentos';
import { BotoneraComponent } from '../../../shared/ui/botonera.component';
import { CajaComponent } from '../../../shared/ui/caja.component';
import { CampoSelectComponent, Opcion } from '../../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../../shared/ui/campo-texto.component';

const TIPOS_RENTA: Opcion[] = [
  { valor: 'TEMPORAL', etiqueta: 'Renta temporal' },
  { valor: 'VIDALICIA', etiqueta: 'Renta vitalicia' },
];

@Component({
  selector: 'app-r2c-captura',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    BotoneraComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Captura de rentas (R2C)">
      <form [formGroup]="form" class="formulario">
        <app-campo-texto [control]="form.controls.documento" etiqueta="Documento tomador" />
        <app-campo-texto
          [control]="form.controls.importe"
          etiqueta="Importe a invertir (€)"
          tipo="number" />
        <app-campo-select
          [control]="form.controls.tipoRenta"
          etiqueta="Tipo de renta"
          [opciones]="tiposRenta" />
        <app-campo-texto
          [control]="form.controls.fechaNacimiento"
          etiqueta="Fecha de nacimiento"
          tipo="date" />
        <app-campo-texto
          [control]="form.controls.duracion"
          etiqueta="Duración (años)"
          tipo="number" />
      </form>
    </app-caja>
    <app-botonera (siguiente)="calcular()" (anterior)="anterior()" />
  `,
  styles: `
    .formulario {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
    }
  `,
})
export class R2cCapturaContainer {
  private readonly store = inject(SesionStore);
  readonly tiposRenta = TIPOS_RENTA;
  readonly form = inject(FormBuilder).nonNullable.group({
    documento: [
      '',
      [
        Validators.required,
        (c: import('@angular/forms').AbstractControl) =>
          esDocumentoIdentidadValido(c.value) ? null : { documento: true },
      ],
    ],
    importe: ['', [Validators.required, Validators.min(1)]],
    tipoRenta: ['VIDALICIA', Validators.required],
    fechaNacimiento: ['', Validators.required],
    duracion: ['10', Validators.required],
  });

  calcular(): void {
    this.store.ejecutar('siguiente', { captura: this.form.getRawValue() }).subscribe();
  }

  anterior(): void {
    this.store.ejecutar('anterior').subscribe();
  }
}
