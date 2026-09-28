/** RESUMEN_CONTRATACION: resumen estructurado (port de TVA_CajaResumenContratacionInformada). */
import { CurrencyPipe, DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit, computed, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';

import {
  EjecutarAccionUsecase,
  PERIODICIDAD_RENTA_ADJETIVO,
  RentasEstado,
  SesionStore,
} from '@tva/core';
import { CajaComponent } from '../../../../shared/ui/contenedores/caja.component';
import { CampoLecturaComponent } from '../../../../shared/ui/formularios/campo-lectura.component';
import { MATERIAL } from '../../../../shared/ui/material';

const PERIODICIDADES: Record<string, string> = {
  M: 'Mensual',
  T: 'Trimestral',
  S: 'Semestral',
  A: 'Anual',
  ...PERIODICIDAD_RENTA_ADJETIVO,
};

interface Tomador {
  datosPersonales?: Record<string, unknown>;
  mediosContacto?: Record<string, unknown>[];
  datosGestionParticipante?: Record<string, unknown>;
}

@Component({
  selector: 'app-resumen-contratacion',
  imports: [
    ...MATERIAL,
    CurrencyPipe,
    DatePipe,
    ReactiveFormsModule,
    CajaComponent,
    CampoLecturaComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './resumen-contratacion.container.html',
  styleUrl: './resumen-contratacion.container.scss',
})
export class ResumenContratacionContainer implements OnInit {
  private readonly store = inject(SesionStore);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  protected readonly form = inject(FormBuilder).nonNullable.group({
    tipoFirma: ['DIGITAL', Validators.required],
  });
  readonly estado = computed(() => (this.store.sesion()?.estado ?? {}) as Record<string, unknown>);

  protected readonly esRenta = computed(
    () => (this.store.sesion()?.modalidad ?? this.estado()['modoFuncionamiento']) === 'R2C'
  );
  protected readonly producto = computed(() => {
    const est = this.estado();
    const codigo = String(est['codigoProducto'] ?? '');
    const sel = est['productoSeleccionado'] as Record<string, unknown> | undefined;
    const lista = (est['productos'] as Record<string, unknown>[] | undefined) ?? [];
    const p = sel ?? lista.find(x => String(x['commercialProductCode']) === codigo);
    const desc = (p?.['commercialProductDesc'] ?? p?.['productDesc'] ?? '') as string;
    return { codigo, desc };
  });
  protected readonly operacion = computed(
    () => (this.estado()['datosOperacion'] ?? {}) as Record<string, unknown>
  );
  protected readonly primaUnica = computed(
    () => this.operacion()['primaUnica'] as number | undefined
  );
  protected readonly aportacionPeriodica = computed(
    () => this.operacion()['aportacionPeriodica'] as number | undefined
  );
  protected readonly fechaEfecto = computed(
    () => this.operacion()['fechaEfecto'] as string | undefined
  );
  protected readonly diaCobro = computed(() => this.operacion()['diaCobro'] as number | undefined);
  protected readonly periodicidad = computed(() => this.operacion()['periodicidad']);
  private readonly rentasEstado = computed(() => (this.estado()['rentas'] ?? {}) as RentasEstado);
  private readonly idxSimulacion = computed(
    () => this.rentasEstado().idxSimulacionSeleccionada ?? null
  );
  protected readonly primaTotalRenta = computed(() => this.rentasEstado().importeTotalPrima);
  protected readonly capitalDecreciente = computed(() => {
    const i = this.idxSimulacion();
    return i !== null
      ? (this.rentasEstado().deathCapitalOptions?.[i]?.deathCapitalPremiumPerc ?? null)
      : null;
  });
  protected readonly renta = computed(() => {
    const directa = this.operacion()['renta'] as number | undefined;
    if (directa !== undefined) return directa;
    if (this.rentasEstado().rentaObjetivo != null) return this.rentasEstado().rentaObjetivo;
    const i = this.idxSimulacion();
    return i !== null ? this.rentasEstado().simulaciones?.[i]?.projectData?.incomeAmn : undefined;
  });
  protected readonly periodicidadRenta = computed(
    () => this.operacion()['periodicidadRenta'] ?? this.rentasEstado().periodicidadRenta
  );
  protected readonly iban = computed(() => {
    const est = this.estado();
    const op = this.operacion();
    const dom = (est['domiciliaciones'] ?? {}) as Record<string, unknown>;
    const t0 = ((est['tomadores'] as Tomador[] | undefined) ?? [])[0];
    const tdom = ((t0 as Record<string, unknown> | undefined)?.['domiciliaciones'] ?? {}) as Record<
      string,
      unknown
    >;
    return (op['ibanRecibos'] ?? dom['ibanRecibos'] ?? tdom['ibanRecibos'] ?? '') as string;
  });
  protected readonly tomadores = computed(
    () => (this.estado()['tomadores'] as Tomador[] | undefined) ?? []
  );
  protected readonly documentos = computed(
    () =>
      (this.estado()['documentosPrecontractuales'] as Record<string, unknown>[] | undefined) ?? []
  );

  protected textoTomador(t: Tomador, campo: string): string {
    const dp = (t.datosPersonales ?? {}) as Record<string, unknown>;
    return String(dp[campo] ?? '');
  }

  protected nombreTomador(t: Tomador): string {
    const dp = (t.datosPersonales ?? {}) as Record<string, unknown>;
    return [dp['nombre'], dp['primerApellido'], dp['segundoApellido']].filter(Boolean).join(' ');
  }

  protected contactoTomador(t: Tomador): { email: string; telefono: string } {
    const medios = t.mediosContacto ?? [];
    const email = medios.find(m => m['tipo'] === 'EMAIL');
    const tel = medios.find(m => m['tipo'] !== 'EMAIL' && (m['numero'] || m['contactMethodValue']));
    return {
      email: (email?.['contactMethodValue'] ?? '') as string,
      telefono: tel
        ? `${(tel['prefijo'] ?? '') as string} ${(tel['numero'] ?? tel['contactMethodValue'] ?? '') as string}`.trim()
        : '',
    };
  }

  protected requisitosTomador(t: Tomador): { etiqueta: string; hecho: boolean }[] {
    const g = (t.datosGestionParticipante ?? {}) as Record<string, unknown>;
    return [
      { etiqueta: 'RGPD', hecho: !!g['consentimientoProteccionDatos'] },
      { etiqueta: 'DNI', hecho: !!g['documentoIdDigitalizado'] },
      { etiqueta: 'Test conveniencia', hecho: !!g['testConvenienciaVigente'] },
    ];
  }

  protected periodicidadEtiqueta(codigo: unknown): string {
    return PERIODICIDADES[String(codigo)] ?? String(codigo ?? '');
  }

  protected firmar(): void {
    this.ejecutarAccion.execute('firmar', { tipoFirma: this.form.value.tipoFirma }).subscribe();
  }

  ngOnInit(): void {
    this.store.datosPendientes.set({ tipoFirma: this.form.value.tipoFirma });
    this.form.valueChanges.subscribe(v => this.store.datosPendientes.set(v));
  }
}
