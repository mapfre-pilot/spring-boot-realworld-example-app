/** RESUMEN_CONTRATACION: cajas resumen + tipo de firma + acción firmar. */
import { ChangeDetectionStrategy, Component, OnInit, computed, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatRadioModule } from '@angular/material/radio';

import { EjecutarAccionUsecase, SesionStore } from '@tva/core';
import { CajaComponent } from '../../../ui/caja.component';

@Component({
  selector: 'app-resumen-contratacion',
  imports: [MatRadioModule, MatButtonModule, ReactiveFormsModule, CajaComponent],
  templateUrl: './resumen-contratacion.container.html',
  styleUrl: './resumen-contratacion.container.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ResumenContratacionContainer implements OnInit {
  private readonly store = inject(SesionStore);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
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
    this.ejecutarAccion.execute('firmar', { tipoFirma: this.form.value.tipoFirma }).subscribe();
  }

  ngOnInit(): void {
    this.store.datosPendientes.set({ tipoFirma: this.form.value.tipoFirma });
    this.form.valueChanges.subscribe(v => this.store.datosPendientes.set(v));
  }
}
