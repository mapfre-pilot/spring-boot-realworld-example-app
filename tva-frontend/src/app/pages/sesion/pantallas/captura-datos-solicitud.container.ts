/** CAPTURA_DATOS_SOLICITUD: operación, inversión, garantías, domiciliaciones. */
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import { SesionStore } from '../../../core/state/sesion.store';
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
  imports: [ReactiveFormsModule, CajaComponent, CampoTextoComponent, CampoSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Datos del seguro">
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
  `,
  styles: `
    .formulario {
      display: grid;
      gap: 8px;
    }
  `,
})
export class CapturaDatosSolicitudContainer implements OnInit {
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

  ngOnInit(): void {
    this.store.datosPendientes.set({ solicitud: this.form.getRawValue() });
    this.form.valueChanges.subscribe(v => this.store.datosPendientes.set({ solicitud: v }));
  }
}
