/** R2C_PRECIOS: opciones de capital decreciente + renta objetivo
 *  (TVA_R2C_SeccionPrecios / TVA_OpcionImporteRenta). */
import { CurrencyPipe, formatCurrency } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, effect, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatRadioModule } from '@angular/material/radio';

import {
  EjecutarAccionUsecase,
  EstadoSesion,
  PERIODICIDAD_RENTA_ADJETIVO,
  PERIODICIDAD_RENTA_ETIQUETA,
  RentasEstado,
  SesionStore,
} from '@tva/core';
import {
  ItemListaDatos,
  ListaDatosComponent,
} from '../../../../../shared/ui/contenedores/lista-datos/lista-datos.component';
import { EncabezadoPantallaComponent } from '../../../../../shared/ui/layout/encabezado-pantalla/encabezado-pantalla.component';

function MONEDA(v: number): string {
  return formatCurrency(v, 'es', '€', 'EUR', '1.2-2');
}

@Component({
  selector: 'app-r2c-precios',
  imports: [
    MatCardModule,
    MatRadioModule,
    MatFormFieldModule,
    MatInputModule,
    ReactiveFormsModule,
    CurrencyPipe,
    ListaDatosComponent,
    EncabezadoPantallaComponent,
  ],
  templateUrl: './r2c-precios.container.html',
  styleUrl: './r2c-precios.container.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class R2cPreciosContainer {
  private readonly store = inject(SesionStore);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);

  private readonly estado = computed(() => (this.store.sesion()?.estado ?? {}) as EstadoSesion);
  protected readonly rentas = computed(() => (this.estado()['rentas'] ?? {}) as RentasEstado);
  protected readonly simulaciones = computed(() => this.rentas().simulaciones ?? []);
  protected readonly opciones = computed(() => this.rentas().deathCapitalOptions ?? []);
  protected readonly idx = computed(() => this.rentas().idxSimulacionSeleccionada ?? null);
  protected readonly periodo = computed(
    () => PERIODICIDAD_RENTA_ETIQUETA[this.rentas().periodicidadRenta ?? ''] ?? 'año'
  );
  protected readonly adjetivo = computed(
    () => PERIODICIDAD_RENTA_ADJETIVO[this.rentas().periodicidadRenta ?? ''] ?? 'anual'
  );
  protected readonly pctSeleccionado = computed(() => {
    const i = this.idx();
    return i !== null ? (this.opciones()[i]?.deathCapitalPremiumPerc ?? null) : null;
  });
  protected readonly recalcular = computed(() => !!this.rentas().recalcular);

  protected itemsSim(i: number): ItemListaDatos[] {
    const sim = this.simulaciones()[i];
    const pct = this.opciones()[i]?.deathCapitalPremiumPerc;
    const items: ItemListaDatos[] = [
      {
        etiqueta: 'Prima total',
        valor: sim?.projectData?.premiumAmn != null ? MONEDA(sim.projectData.premiumAmn) : null,
      },
      {
        etiqueta: 'Rentabilidad esperada',
        valor:
          sim?.projectData?.expectedReturnPerc != null
            ? `${sim.projectData.expectedReturnPerc}%`
            : null,
      },
      {
        etiqueta: 'Capital decreciente',
        valor: pct != null ? `hasta el ${pct}%` : null,
      },
    ];
    this.rentaTomador(i).forEach((r, j) =>
      items.push({ etiqueta: `Renta Tomador ${j + 1}`, valor: MONEDA(r) })
    );
    return items;
  }

  protected rentaTomador(i: number): number[] {
    const income = this.simulaciones()[i]?.projectData?.incomeAmn ?? 0;
    return (this.estado().tomadores ?? [])
      .slice(0, 2)
      .map(t => income * (Number(t.datosPersonales?.['participationPerc'] ?? 0) / 100));
  }

  readonly rentaControl = new FormControl<number | null>(null);

  constructor() {
    effect(() => {
      this.rentaControl.setValue(this.rentas().rentaObjetivo ?? null, { emitEvent: false });
    });
  }

  protected seleccionar(i: number): void {
    this.ejecutarAccion.execute('actualizar-rentas', { idxSimulacionSeleccionada: i }).subscribe();
  }

  cambiarRenta(): void {
    const v = this.rentaControl.value;
    if (v !== null && v !== this.rentas().rentaObjetivo) {
      this.ejecutarAccion.execute('actualizar-rentas', { rentaObjetivo: v }).subscribe();
    }
  }
}
