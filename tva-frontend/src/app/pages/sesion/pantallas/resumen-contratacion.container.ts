/** RESUMEN_CONTRATACION: cajas resumen + tipo de firma + acción firmar. */
import { ChangeDetectionStrategy, Component, OnInit, computed, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatRadioModule } from '@angular/material/radio';

import { SesionStore } from '../../../core/state/sesion.store';
import { CajaComponent } from '../../../shared/ui/caja.component';

@Component({
  selector: 'app-resumen-contratacion',
  imports: [MatRadioModule, MatButtonModule, ReactiveFormsModule, CajaComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-caja titulo="Solicitud">
      <pre>{{ estadoJson('solicitud') }}</pre>
    </app-caja>
    <app-caja titulo="Tomador(es)">
      <pre>{{ estadoJson('tomador') }}</pre>
    </app-caja>
    <app-caja titulo="Producto / rentas">
      <pre>{{ estadoJson('producto') }}</pre>
    </app-caja>
    <app-caja titulo="Tipo de firma">
      <form [formGroup]="form">
        <mat-radio-group formControlName="tipoFirma">
          <mat-radio-button value="DIGITAL">Firma digital</mat-radio-button>
          <mat-radio-button value="MANUSCRITA">Firma manuscrita</mat-radio-button>
        </mat-radio-group>
      </form>
    </app-caja>
    <button mat-flat-button color="primary" (click)="firmar()" [disabled]="form.invalid">
      Firmar y contratar
    </button>
  `,
  styles: `
    pre {
      white-space: pre-wrap;
      font-size: 0.85em;
    }
    mat-radio-button {
      display: block;
      margin: 4px 0;
    }
  `,
})
export class ResumenContratacionContainer implements OnInit {
  private readonly store = inject(SesionStore);
  readonly form = inject(FormBuilder).nonNullable.group({
    tipoFirma: ['DIGITAL', Validators.required],
  });
  readonly estado = computed(() => this.store.sesion()?.estado ?? {});

  estadoJson(clave: string): string {
    return JSON.stringify(
      (this.estado() as Record<string, unknown>)[clave] ?? this.estado(),
      null,
      2
    );
  }

  firmar(): void {
    this.store.ejecutar('firmar', { tipoFirma: this.form.value.tipoFirma }).subscribe();
  }

  ngOnInit(): void {
    this.store.datosPendientes.set({ tipoFirma: this.form.value.tipoFirma });
    this.form.valueChanges.subscribe(v => this.store.datosPendientes.set(v));
  }
}
