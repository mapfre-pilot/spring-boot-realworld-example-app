/** Pantalla de inicio: documento, canal, productor, modalidad → inicio/*. */
import { ChangeDetectionStrategy, Component, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { Router } from '@angular/router';

import { TvaApiService } from '../../core/api/tva-api.service';
import { Canal, Modalidad } from '../../core/models/models';
import { esDocumentoIdentidadValido } from '../../core/validaciones/documentos';
import { CabeceraComponent } from '../../shared/ui/cabecera.component';
import { CampoSelectComponent, Opcion } from '../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../shared/ui/campo-texto.component';

const CANALES: Opcion[] = [
  { valor: 'GV', etiqueta: 'Gestor de vida (GV)' },
  { valor: 'PFM', etiqueta: 'Portal financiero MAPFRE (PFM)' },
  { valor: 'OTRO', etiqueta: 'Otro' },
];

const MODALIDADES: Opcion[] = [
  { valor: 'VA', etiqueta: 'Venta asesorada (VA)' },
  { valor: 'VIA', etiqueta: 'Venta informada ahorro (VIA)' },
  { valor: 'R2C', etiqueta: 'Rentas (R2C)' },
];

@Component({
  selector: 'app-inicio-page',
  imports: [
    ReactiveFormsModule,
    MatCardModule,
    MatButtonModule,
    CabeceraComponent,
    CampoTextoComponent,
    CampoSelectComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-cabecera />
    <div class="pagina">
      <mat-card>
        <mat-card-title>Nueva sesión de tarificación</mat-card-title>
        <mat-card-content>
          <form [formGroup]="form" (ngSubmit)="iniciar()">
            <app-campo-texto
              [control]="form.controls.documentoCliente"
              etiqueta="Documento cliente (NIF/NIE/CIF)" />
            <app-campo-select
              [control]="form.controls.canal"
              etiqueta="Canal"
              [opciones]="canales" />
            <app-campo-select
              [control]="form.controls.modalidad"
              etiqueta="Modalidad"
              [opciones]="modalidades" />
            <app-campo-texto
              [control]="form.controls.codigoProductor"
              etiqueta="Código productor" />
            <button
              mat-flat-button
              color="primary"
              type="submit"
              [disabled]="form.invalid || cargando()">
              Iniciar sesión
            </button>
          </form>
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: `
    .pagina {
      max-width: 560px;
      margin: 24px auto;
      padding: 0 16px;
    }
  `,
})
export class InicioPage {
  private readonly api = inject(TvaApiService);
  private readonly router = inject(Router);

  readonly cargando = signal(false);
  readonly canales = CANALES;
  readonly modalidades = MODALIDADES;
  readonly form = inject(FormBuilder).nonNullable.group({
    documentoCliente: [
      '',
      [
        Validators.required,
        (c: import('@angular/forms').AbstractControl) =>
          esDocumentoIdentidadValido(c.value) ? null : { documento: true },
      ],
    ],
    canal: ['GV' as Canal, Validators.required],
    modalidad: ['VA' as Modalidad, Validators.required],
    codigoProductor: [''],
  });

  iniciar(): void {
    const v = this.form.getRawValue();
    const req = {
      documentoCliente: v.documentoCliente,
      canal: v.canal,
      codigoProductor: v.codigoProductor,
    };
    this.cargando.set(true);
    const obs = v.modalidad === 'R2C' ? this.api.inicioRentas(req) : this.api.inicioAhorro(req);
    obs.subscribe({
      next: r => {
        this.cargando.set(false);
        void this.router.navigate(['/sesion', r.claveSesion]);
      },
      error: () => this.cargando.set(false),
    });
  }
}
