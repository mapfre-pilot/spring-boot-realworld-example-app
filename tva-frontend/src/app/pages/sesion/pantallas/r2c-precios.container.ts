/** R2C_PRECIOS: opciones de capital decreciente + renta objetivo
 *  (TVA_R2C_SeccionPrecios / TVA_OpcionImporteRenta). */
import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatRadioModule } from '@angular/material/radio';

import {
  EjecutarAccionUsecase,
  EstadoSesion,
  PERIODICIDAD_RENTA_ADJETIVO,
  PERIODICIDAD_RENTA_ETIQUETA,
  RentasEstado,
  SesionStore,
} from '@tva/core';
import { CajaComponent } from '../../../ui/caja.component';

@Component({
  selector: 'app-r2c-precios',
  imports: [MatCardModule, MatRadioModule, ReactiveFormsModule, CurrencyPipe, CajaComponent],
  templateUrl: './r2c-precios.container.html',
  styleUrl: './r2c-precios.container.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class R2cPreciosContainer {
  private readonly store = inject(SesionStore);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);

  private readonly estado = computed(() => (this.store.sesion()?.estado ?? {}) as EstadoSesion);
  readonly rentas = computed(() => (this.estado()['rentas'] ?? {}) as RentasEstado);
  readonly simulaciones = computed(() => this.rentas().simulaciones ?? []);
  readonly opciones = computed(() => this.rentas().deathCapitalOptions ?? []);
  readonly idx = computed(() => this.rentas().idxSimulacionSeleccionada ?? null);
  readonly periodo = computed(
    () => PERIODICIDAD_RENTA_ETIQUETA[this.rentas().periodicidadRenta ?? ''] ?? 'año'
  );
  readonly adjetivo = computed(
    () => PERIODICIDAD_RENTA_ADJETIVO[this.rentas().periodicidadRenta ?? ''] ?? 'anual'
  );
  readonly pctSeleccionado = computed(() => {
    const i = this.idx();
    return i !== null ? (this.opciones()[i]?.deathCapitalPremiumPerc ?? null) : null;
  });
  readonly rentaTomador = computed(() => {
    const i = this.idx();
    const income = i !== null ? (this.simulaciones()[i]?.projectData?.incomeAmn ?? 0) : 0;
    return (this.estado().tomadores ?? [])
      .slice(0, 2)
      .map(t => income * (Number(t.datosPersonales?.['participationPerc'] ?? 0) / 100));
  });

  readonly rentaControl = new FormControl<number | null>(null);

  seleccionar(i: number): void {
    this.ejecutarAccion.execute('actualizar-rentas', { idxSimulacionSeleccionada: i }).subscribe();
  }

  cambiarRenta(): void {
    const v = this.rentaControl.value;
    if (v !== null && v !== this.rentas().rentaObjetivo) {
      this.ejecutarAccion.execute('actualizar-rentas', { rentaObjetivo: v }).subscribe();
    }
  }
}
