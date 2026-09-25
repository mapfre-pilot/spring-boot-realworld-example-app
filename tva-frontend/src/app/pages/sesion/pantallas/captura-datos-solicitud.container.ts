/** CAPTURA_DATOS_SOLICITUD — coordina las cajas del seguro (subcomponentes presentacionales). */
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormBuilder } from '@angular/forms';

import { SesionStore, ValidarSeccionUsecase, crearFormulariosSolicitud } from '@tva/core';
import { CajaComponent } from '../../../ui/caja.component';
import { Opcion } from '../../../ui/campo-select.component';
import { CapturaAmpliadaComponent } from './solicitud/captura-ampliada.component';
import { DatosOperacionComponent } from './solicitud/datos-operacion.component';
import { DatosProductoresComponent } from './solicitud/datos-productores.component';
import { DomiciliacionesComponent } from './solicitud/domiciliaciones.component';
import { Garantia, GarantiasComponent } from './solicitud/garantias.component';
import {
  ImporteOpcion,
  OpcionInversion,
  OpcionesInversionComponent,
} from './solicitud/opciones-inversion.component';

const TIPOS_DURACION: Opcion[] = [
  { valor: 'ANIOS', etiqueta: 'Años' },
  { valor: 'TABLA', etiqueta: 'Tabla' },
  { valor: 'EDAD_VENCIMIENTO', etiqueta: 'Edad de vencimiento' },
  { valor: 'FECHA_VENCIMIENTO', etiqueta: 'Fecha de vencimiento' },
  { valor: 'JUBILACION', etiqueta: 'Jubilación' },
];

const TIPOS_BENEFICIARIO: Opcion[] = [
  { valor: 'HEREDEROS', etiqueta: 'Herederos legales' },
  { valor: 'HIJOS', etiqueta: 'Hijos' },
  { valor: 'PADRES', etiqueta: 'Padres' },
  { valor: 'CONYUGE', etiqueta: 'Cónyuge' },
  { valor: 'TOMADOR', etiqueta: 'Tomador' },
  { valor: 'HERMANOS', etiqueta: 'Hermanos' },
  { valor: 'TEXTO_LIBRE', etiqueta: 'Texto libre' },
];

const PERIODICIDADES: Opcion[] = [
  { valor: 'M', etiqueta: 'Mensual' },
  { valor: 'T', etiqueta: 'Trimestral' },
  { valor: 'S', etiqueta: 'Semestral' },
  { valor: 'A', etiqueta: 'Anual' },
];

const SECCIONES: [string, string][] = [
  ['DATOS_PRODUCTORES', 'productores'],
  ['DATOS_DEL_SEGURO', 'operacion'],
  ['DATOS_DEL_SEGURO', 'opcionesInversion'],
  ['DATOS_DEL_SEGURO', 'garantias'],
  ['DATOS_DEL_SEGURO', 'domiciliaciones'],
  ['DATOS_DEL_SEGURO', 'datosContacto'],
  ['DATOS_DEL_SEGURO', 'asegurado'],
  ['DATOS_DEL_SEGURO', 'beneficiarios'],
  ['DATOS_DEL_SEGURO', 'notas'],
];

@Component({
  selector: 'app-captura-datos-solicitud',
  imports: [
    CajaComponent,
    DatosProductoresComponent,
    DatosOperacionComponent,
    OpcionesInversionComponent,
    GarantiasComponent,
    DomiciliacionesComponent,
    CapturaAmpliadaComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './captura-datos-solicitud.container.html',
})
export class CapturaDatosSolicitudContainer implements OnInit {
  private readonly store = inject(SesionStore);
  private readonly fb = inject(FormBuilder);
  private readonly validarSeccion = inject(ValidarSeccionUsecase);

  readonly tiposDuracion = TIPOS_DURACION;
  readonly tiposBeneficiario = TIPOS_BENEFICIARIO;
  readonly avisos = this.store.avisos;
  readonly ampliada = signal(false);
  readonly expandida = signal<string>('productores');
  readonly validas = signal<Record<string, boolean>>({});
  readonly opcionSel = signal<boolean[]>([]);
  readonly importes = signal<Record<string, ImporteOpcion>>({});

  readonly estado = computed(() => this.store.sesion()?.estado);
  readonly producto = computed(
    () =>
      ((this.estado() as Record<string, unknown> | undefined)?.['productoSeleccionado'] as
        | Record<string, unknown>
        | undefined) ??
      (
        ((this.estado() as Record<string, unknown> | undefined)?.['productos'] as
          | Record<string, unknown>[]
          | undefined) ?? []
      ).find(
        (p: Record<string, unknown>) =>
          String(p['commercialProductCode']) === String(this.estado()?.codigoProducto)
      )
  );
  readonly opcionesProducto = computed(
    () => (this.producto()?.['opcionesInversion'] ?? []) as OpcionInversion[]
  );
  readonly garantias = computed(
    () =>
      ((this.estado() as Record<string, unknown> | undefined)?.['garantias'] ??
        []) as unknown as Garantia[]
  );
  readonly periodicidadesProducto = computed(() => {
    const codigos = this.producto()?.['periodicidades'] as string[] | undefined;
    return PERIODICIDADES.filter(p => !codigos || codigos.includes(p.valor));
  });
  /** Validez por sección para la plantilla (`CAJA/seccion` → bool). */
  readonly validez = computed(() => {
    const map: Record<string, boolean> = {};
    for (const [cajaId, seccionId] of SECCIONES) {
      const key = `${cajaId}/${seccionId}`;
      if (key in this.validas()) {
        map[key] = this.validas()[key];
      } else {
        const caja = (this.estado()?.cajas ?? []).find(c => c.id === cajaId);
        map[key] = caja?.secciones.find(s => s.id === seccionId)?.datosValidos ?? false;
      }
    }
    return map;
  });

  readonly formularios = crearFormulariosSolicitud(this.fb.nonNullable);

  ngOnInit(): void {
    const est = this.estado();
    const e = est as Record<string, unknown> | undefined;
    if (e?.['datosProductores'])
      this.formularios.productores.patchValue(e['datosProductores'] as never);
    if (e?.['datosOperacion']) this.formularios.operacion.patchValue(e['datosOperacion'] as never);
    if (e?.['domiciliaciones'])
      this.formularios.domiciliaciones.patchValue(e['domiciliaciones'] as never);
    if (e?.['datosContacto'])
      this.formularios.datosContacto.patchValue(e['datosContacto'] as never);
    if (e?.['asegurado']) this.formularios.asegurado.patchValue(e['asegurado'] as never);
    if (e?.['beneficiarios'])
      this.formularios.beneficiarios.patchValue(e['beneficiarios'] as never);
    const sel = ((e?.['ventaInformada'] as Record<string, unknown> | undefined)?.[
      'opcionesInversion'
    ] ?? []) as { seleccionada?: boolean }[];
    this.opcionSel.set(this.opcionesProducto().map((_, i) => sel[i]?.seleccionada ?? false));
    const imp: Record<string, ImporteOpcion> = {};
    this.opcionesProducto().forEach((_, i) => {
      const o = sel[i] as Record<string, unknown> | undefined;
      imp[i] = {
        unica: (o?.['primaUnica'] as number | undefined) ?? undefined,
        periodica: (o?.['primaPeriodica'] as number | undefined) ?? undefined,
        plazo: (o?.['plazoObjetivo'] as number | undefined) ?? undefined,
      };
    });
    this.importes.set(imp);
  }

  private _post(cajaId: string, seccionId: string, datos: unknown, siguiente?: string): void {
    this.validarSeccion
      .execute(cajaId, seccionId, datos as Record<string, unknown>)
      .subscribe(res => {
        const ref = `${cajaId}/${seccionId}`;
        const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
        this.validas.update(v => ({ ...v, [ref]: !hayErrores }));
        if (!hayErrores && siguiente !== undefined) this.expandida.set(siguiente);
      });
  }

  continuarSeccion(
    seccionId: 'operacion' | 'domiciliaciones' | 'datosContacto' | 'beneficiarios'
  ): void {
    this._post('DATOS_DEL_SEGURO', seccionId, this.formularios[seccionId].getRawValue(), '');
  }

  continuarProductores(): void {
    this._post(
      'DATOS_PRODUCTORES',
      'productores',
      this.formularios.productores.getRawValue(),
      'operacion'
    );
  }

  seleccionarOpcion(i: number, sel: boolean): void {
    this.opcionSel.update(v => v.map((b, j) => (j === i ? sel : b)));
    if (sel && this.opcionesProducto().length && !this.importes()[i]?.unica) {
      // primera selección: auto-asignar el importe de la prima única
      const prima = this.formularios.operacion.value.primaUnica;
      this.importes.update(m => ({ ...m, [i]: { ...m[i], unica: prima ?? undefined } }));
    }
  }

  setImporte(i: number, campo: 'unica' | 'periodica' | 'plazo', ev: Event): void {
    const v = (ev.target as HTMLInputElement).valueAsNumber;
    this.importes.update(m => ({
      ...m,
      [i]: { ...m[i], [campo]: Number.isNaN(v) ? undefined : v },
    }));
  }

  suma(campo: 'unica' | 'periodica'): number {
    return this.opcionesProducto().reduce(
      (acc, _, i) => (this.opcionSel()[i] ? acc + (this.importes()[i]?.[campo] ?? 0) : acc),
      0
    );
  }

  continuarOpciones(): void {
    const opciones = this.opcionesProducto().map((o, i) => ({
      ...o,
      seleccionada: !!this.opcionSel()[i],
      primaUnica: this.importes()[i]?.unica,
      primaPeriodica: this.importes()[i]?.periodica,
      plazoObjetivo: this.importes()[i]?.plazo,
    }));
    this._post('DATOS_DEL_SEGURO', 'opcionesInversion', opciones, 'garantias');
  }

  toggleGarantia(i: number, sel: boolean): void {
    const est = this.estado();
    const garantias = (((est?.garantias as unknown) ?? []) as Garantia[]).map((g, j) =>
      j === i ? { ...g, seleccionada: sel } : g
    );
    (est as Record<string, unknown>)['garantias'] = garantias;
  }

  continuarGarantias(): void {
    this._post('DATOS_DEL_SEGURO', 'garantias', this.garantias(), 'domiciliaciones');
  }

  continuarAmpliada(seccionId: string): void {
    switch (seccionId) {
      case 'datosContacto':
        this._post(
          'DATOS_DEL_SEGURO',
          'datosContacto',
          this.formularios.datosContacto.getRawValue(),
          ''
        );
        break;
      case 'asegurado':
        this._post('DATOS_DEL_SEGURO', 'asegurado', this.formularios.asegurado.getRawValue(), '');
        break;
      case 'beneficiarios':
        this._post(
          'DATOS_DEL_SEGURO',
          'beneficiarios',
          this.formularios.beneficiarios.getRawValue(),
          ''
        );
        break;
      case 'notas': {
        const texto = this.formularios.nota.value.texto;
        const notas = texto ? [{ texto, seleccionada: true }] : [];
        this._post('DATOS_DEL_SEGURO', 'notas', notas, '');
        break;
      }
    }
  }
}
