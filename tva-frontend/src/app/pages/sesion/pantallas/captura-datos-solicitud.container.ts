/** CAPTURA_DATOS_SOLICITUD: importe, periodicidad, fecha efecto, opciones de inversión. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';

import { SesionStore } from '../../../core/state/sesion.store';
import { BotoneraComponent } from '../../../shared/ui/botonera.component';
import { CajaComponent } from '../../../shared/ui/caja.component';
import { CampoSelectComponent, Opcion } from '../../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../../shared/ui/campo-texto.component';

const PERIODICIDADES: Opcion[] = [
  { valor: 'ANUAL', etiqueta: 'Anual' },
  { valor: 'SEMESTRAL', etiqueta: 'Semestral' },
  { valor: 'TRIMESTRAL', etiqueta: 'Trimestral' },
  { valor: 'MENSUAL', etiqueta: 'Mensual' },
];

const OPCIONES_INVERSION: Opcion[] = [
  { valor: 'FIJO', etiqueta: 'Interés fijo garantizado' },
  { valor: 'UNIDADES', etiqueta: 'Fondo de inversión (unidades)' },
  { valor: 'MIXTO', etiqueta: 'Mixto' },
];

@Component({
  selector: 'app-captura-datos-solicitud',
  imports: [
    ReactiveFormsModule,
    MatButtonModule,
    CajaComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    BotoneraComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Datos de la solicitud">
      <form [formGroup]="form" class="formulario">
        <app-campo-texto [control]="form.controls.importe" etiqueta="Importe (€)" tipo="number" />
        <app-campo-select
          [control]="form.controls.periodicidad"
          etiqueta="Periodicidad"
          [opciones]="periodicidades" />
        <app-campo-texto
          [control]="form.controls.fechaEfecto"
          etiqueta="Fecha efecto"
          tipo="date" />
        <app-campo-select
          [control]="form.controls.opcionInversion"
          etiqueta="Opción de inversión"
          [opciones]="opcionesInversion" />
        <app-campo-texto
          [control]="form.controls.duracion"
          etiqueta="Duración (años)"
          tipo="number" />
      </form>
    </app-caja>
    <app-botonera (siguiente)="guardar()" (anterior)="anterior()" (guardar)="guardarYVolver()" />
  `,
  styles: `
    .formulario {
      display: grid;
      gap: 8px;
    }
  `,
})
export class CapturaDatosSolicitudContainer {
  private readonly store = inject(SesionStore);

  readonly periodicidades = PERIODICIDADES;
  readonly opcionesInversion = OPCIONES_INVERSION;
  readonly form = inject(FormBuilder).nonNullable.group({
    importe: ['', [Validators.required, Validators.min(1)]],
    periodicidad: ['ANUAL', Validators.required],
    fechaEfecto: ['', Validators.required],
    opcionInversion: ['FIJO', Validators.required],
    duracion: ['5', Validators.required],
  });

  guardar(): void {
    this.store.ejecutar('guardar-solicitud', { solicitud: this.form.getRawValue() }).subscribe();
  }

  guardarYVolver(): void {
    this.store.guardarEstado({ solicitud: this.form.getRawValue() }).subscribe();
  }

  anterior(): void {
    this.store.ejecutar('anterior').subscribe();
  }
}
