/** CAPTURA_DATOS_SOLICITUD — cajas del seguro con secciones y validar-seccion (§12.4.4). */
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';

import { SesionStore } from '../../../core/state/sesion.store';
import { CajaComponent } from '../../../shared/ui/caja.component';
import { CampoSelectComponent, Opcion } from '../../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../../shared/ui/campo-texto.component';
import { SeccionComponent } from '../../../shared/ui/seccion.component';
import { esIbanValido } from '../../../core/validaciones/documentos';

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

@Component({
  selector: 'app-captura-datos-solicitud',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    MatCheckboxModule,
    MatSlideToggleModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="migas">Tomador 1 › <b>Solicitud</b> › Resumen</div>
    @if (producto(); as p) {
      <h3>{{ p['commercialProductCode'] }} - {{ p['commercialProductDesc'] }}</h3>
    }

    <app-caja titulo="Datos de productores">
      <app-seccion
        titulo="Productores"
        [valida]="seccionValida('DATOS_PRODUCTORES', 'productores')"
        [expandida]="expandida() === 'productores'"
        [avisos]="avisos()"
        seccion="DATOS_PRODUCTORES/productores"
        (continuar)="continuarProductores()">
        <form [formGroup]="productores" class="formulario">
          <app-campo-texto [control]="productores.controls.oficina" etiqueta="Oficina" />
          <app-campo-texto [control]="productores.controls.productor" etiqueta="Productor" />
          <app-campo-texto
            [control]="productores.controls.comisionMaxima"
            etiqueta="% comisión máxima 1er año"
            tipo="number" />
          <app-campo-texto
            [control]="productores.controls.comisionDeseada"
            etiqueta="% comisión deseada 1er año"
            tipo="number" />
          <mat-checkbox formControlName="aportacionPlanificada"
            >Aportación Planificada</mat-checkbox
          >
          <mat-checkbox formControlName="aportacionExtraordinaria"
            >Aportación Extraordinaria</mat-checkbox
          >
        </form>
      </app-seccion>
    </app-caja>

    <app-caja titulo="Datos del seguro">
      <app-seccion
        titulo="Datos de la operación"
        [valida]="seccionValida('DATOS_DEL_SEGURO', 'operacion')"
        [expandida]="expandida() === 'operacion'"
        [avisos]="avisos()"
        seccion="DATOS_DEL_SEGURO/operacion"
        (continuar)="continuarSeccion('operacion', operacion)">
        <form [formGroup]="operacion" class="formulario">
          <app-campo-texto
            [control]="operacion.controls.fechaEfecto"
            etiqueta="Fecha de efecto"
            tipo="date" />
          <app-campo-select
            [control]="operacion.controls.tipoDuracion"
            etiqueta="Tipo de duración"
            [opciones]="tiposDuracion" />
          @if (operacion.value.tipoDuracion === 'ANIOS') {
            <app-campo-texto
              [control]="operacion.controls.duracion"
              etiqueta="Duración (años)"
              tipo="number" />
          }
          @if (operacion.value.tipoDuracion === 'TABLA') {
            <app-campo-texto [control]="operacion.controls.tabla" etiqueta="Tabla" />
          }
          @if (operacion.value.tipoDuracion === 'EDAD_VENCIMIENTO') {
            <app-campo-texto
              [control]="operacion.controls.edadVencimiento"
              etiqueta="Edad de vencimiento"
              tipo="number" />
          }
          @if (operacion.value.tipoDuracion === 'FECHA_VENCIMIENTO') {
            <app-campo-texto
              [control]="operacion.controls.fechaVencimiento"
              etiqueta="Fecha de vencimiento"
              tipo="date" />
          }
          <app-campo-texto
            [control]="operacion.controls.primaUnica"
            etiqueta="Prima única (€)"
            tipo="number" />
          <app-campo-texto
            [control]="operacion.controls.aportacionPeriodica"
            etiqueta="Aportación periódica (€)"
            tipo="number" />
          @if (operacion.value.aportacionPeriodica) {
            <app-campo-select
              [control]="operacion.controls.periodicidad"
              etiqueta="Periodicidad"
              [opciones]="periodicidadesProducto()" />
            <app-campo-texto
              [control]="operacion.controls.diaCobro"
              etiqueta="Día de cobro"
              tipo="number" />
          }
          <mat-slide-toggle formControlName="revalorizacion"
            >¿Quieres revalorizar tu aportación?</mat-slide-toggle
          >
          @if (operacion.value.revalorizacion) {
            <app-campo-texto
              [control]="operacion.controls.porcentajeCrecimiento"
              etiqueta="Porcentaje anual de crecimiento (%)"
              tipo="number" />
          }
          <mat-slide-toggle formControlName="reinversionActiva">Reinversión</mat-slide-toggle>
          @if (operacion.value.reinversionActiva) {
            <app-campo-texto
              [control]="operacion.controls.reinversionOperacion"
              etiqueta="Operación" />
            <app-campo-texto [control]="operacion.controls.reinversionPoliza" etiqueta="Póliza" />
            <app-campo-texto
              [control]="operacion.controls.reinversionTipo"
              etiqueta="Tipo de reinversión" />
          }
          <app-campo-texto
            [control]="operacion.controls.gradoMinusvalia"
            etiqueta="Grado de minusvalía (%)"
            tipo="number" />
          @if (operacion.value.gradoMinusvalia) {
            <app-campo-texto
              [control]="operacion.controls.fechaAltaMinusvalia"
              etiqueta="Fecha de alta de la minusvalía"
              tipo="date" />
          }
        </form>
      </app-seccion>

      <app-seccion
        titulo="Opciones de inversión"
        [valida]="seccionValida('DATOS_DEL_SEGURO', 'opcionesInversion')"
        [expandida]="expandida() === 'opcionesInversion'"
        [avisos]="avisos()"
        seccion="DATOS_DEL_SEGURO/opcionesInversion"
        (continuar)="continuarOpciones()">
        @if (opcionesProducto().length) {
          <table class="tabla">
            <thead>
              <tr>
                <th></th>
                <th>Código</th>
                <th>Descripción</th>
                <th>Prima única</th>
                <th>Prima periódica</th>
                <th>Plazo objetivo</th>
              </tr>
            </thead>
            <tbody>
              @for (o of opcionesProducto(); track o.investmentPreferenceCode; let i = $index) {
                <tr>
                  <td>
                    <mat-checkbox
                      [checked]="opcionSel()[i]"
                      (change)="seleccionarOpcion(i, $event.checked)" />
                  </td>
                  <td>{{ o.investmentPreferenceCode }}</td>
                  <td>{{ o.descripcion }}</td>
                  <td>
                    <input
                      class="num"
                      type="number"
                      [value]="importe(i, 'unica')"
                      (change)="setImporte(i, 'unica', $event)" />
                  </td>
                  <td>
                    <input
                      class="num"
                      type="number"
                      [value]="importe(i, 'periodica')"
                      (change)="setImporte(i, 'periodica', $event)" />
                  </td>
                  <td>
                    <input
                      class="num"
                      type="number"
                      [value]="importe(i, 'plazo')"
                      (change)="setImporte(i, 'plazo', $event)" />
                  </td>
                </tr>
              }
            </tbody>
          </table>
          <div class="suma">
            Suma prima única: {{ suma('unica') }} € / periódica: {{ suma('periodica') }} €
          </div>
        } @else {
          <p>Este producto no tiene opciones de inversión configurables.</p>
        }
      </app-seccion>

      <app-seccion
        titulo="Garantías"
        [valida]="seccionValida('DATOS_DEL_SEGURO', 'garantias')"
        [expandida]="expandida() === 'garantias'"
        [avisos]="avisos()"
        seccion="DATOS_DEL_SEGURO/garantias"
        (continuar)="continuarGarantias()">
        @for (g of garantias(); track g.codigo; let i = $index) {
          <mat-checkbox
            [checked]="!!g.seleccionada"
            [disabled]="g.obligatoria"
            (change)="toggleGarantia(i, $event.checked)">
            {{ g.codigo }} - {{ g.descripcion }} {{ g.obligatoria ? '(obligatoria)' : '' }}
          </mat-checkbox>
        }
      </app-seccion>

      <app-seccion
        titulo="Domiciliaciones"
        [valida]="seccionValida('DATOS_DEL_SEGURO', 'domiciliaciones')"
        [expandida]="expandida() === 'domiciliaciones'"
        [avisos]="avisos()"
        seccion="DATOS_DEL_SEGURO/domiciliaciones"
        (continuar)="continuarSeccion('domiciliaciones', domiciliaciones)">
        <form [formGroup]="domiciliaciones" class="formulario">
          <app-campo-texto
            [control]="domiciliaciones.controls.ibanRecibos"
            etiqueta="IBAN recibos" />
          @if (requierePrestaciones()) {
            <app-campo-texto
              [control]="domiciliaciones.controls.ibanPrestaciones"
              etiqueta="IBAN prestaciones" />
          }
          <mat-slide-toggle formControlName="requierePrestaciones"
            >Requiere prestaciones</mat-slide-toggle
          >
        </form>
      </app-seccion>
    </app-caja>

    <mat-slide-toggle [checked]="ampliada()" (change)="ampliada.set($event.checked)">
      Ampliar captura de datos (beneficiarios, datos de contacto, etc.)
    </mat-slide-toggle>
    @if (ampliada()) {
      <app-caja titulo="Datos de contacto">
        <app-seccion
          titulo="Dirección de correspondencia"
          [valida]="seccionValida('DATOS_DEL_SEGURO', 'datosContacto')"
          [expandida]="expandida() === 'datosContacto'"
          [avisos]="avisos()"
          seccion="DATOS_DEL_SEGURO/datosContacto"
          (continuar)="continuarSeccion('datosContacto', datosContacto)">
          <form [formGroup]="datosContacto" class="formulario">
            <app-campo-select
              [control]="datosContacto.controls.tipoDireccion"
              etiqueta="Tipo de dirección"
              [opciones]="[
                { valor: 'CORRESPONDENCIA', etiqueta: 'Correspondencia' },
                { valor: 'FISCAL', etiqueta: 'Fiscal' },
              ]" />
            <app-campo-texto [control]="datosContacto.controls.tipoVia" etiqueta="Tipo de vía" />
            <app-campo-texto
              [control]="datosContacto.controls.nombreVia"
              etiqueta="Nombre de la vía" />
            <app-campo-texto [control]="datosContacto.controls.numero" etiqueta="Número" />
            <app-campo-texto
              [control]="datosContacto.controls.codigoPostal"
              etiqueta="Código postal" />
            <app-campo-texto [control]="datosContacto.controls.localidad" etiqueta="Localidad" />
            <app-campo-texto [control]="datosContacto.controls.provincia" etiqueta="Provincia" />
            <app-campo-texto [control]="datosContacto.controls.pais" etiqueta="País" />
          </form>
        </app-seccion>
      </app-caja>
      <app-caja titulo="Asegurado">
        <app-seccion
          titulo="Asegurado"
          [valida]="seccionValida('DATOS_DEL_SEGURO', 'asegurado')"
          [expandida]="expandida() === 'asegurado'"
          [avisos]="avisos()"
          seccion="DATOS_DEL_SEGURO/asegurado"
          (continuar)="continuarAsegurado()">
          <form [formGroup]="asegurado">
            <mat-slide-toggle formControlName="esTomador"
              >El asegurado es el tomador</mat-slide-toggle
            >
          </form>
          @if (!asegurado.value.esTomador) {
            <form [formGroup]="asegurado" class="formulario">
              <app-campo-texto [control]="asegurado.controls.nombre" etiqueta="Nombre" />
              <app-campo-texto
                [control]="asegurado.controls.primerApellido"
                etiqueta="Primer apellido" />
              <app-campo-texto
                [control]="asegurado.controls.fechaNacimiento"
                etiqueta="Fecha de nacimiento"
                tipo="date" />
              <app-campo-texto [control]="asegurado.controls.sexo" etiqueta="Sexo" />
              <app-campo-texto [control]="asegurado.controls.parentesco" etiqueta="Parentesco" />
            </form>
          }
        </app-seccion>
      </app-caja>
      <app-caja titulo="Beneficiarios">
        <app-seccion
          titulo="Beneficiarios"
          [valida]="seccionValida('DATOS_DEL_SEGURO', 'beneficiarios')"
          [expandida]="expandida() === 'beneficiarios'"
          [avisos]="avisos()"
          seccion="DATOS_DEL_SEGURO/beneficiarios"
          (continuar)="continuarSeccion('beneficiarios', beneficiarios)">
          <form [formGroup]="beneficiarios" class="formulario">
            <app-campo-select
              [control]="beneficiarios.controls.tipo"
              etiqueta="Tipo de beneficiario"
              [opciones]="tiposBeneficiario" />
            @if (beneficiarios.value.tipo === 'TEXTO_LIBRE') {
              <app-campo-texto
                [control]="beneficiarios.controls.textoLibre"
                etiqueta="Texto libre" />
            }
          </form>
        </app-seccion>
      </app-caja>
      <app-caja titulo="Notas">
        <app-seccion
          titulo="Notas"
          [valida]="seccionValida('DATOS_DEL_SEGURO', 'notas')"
          [expandida]="expandida() === 'notas'"
          [avisos]="avisos()"
          seccion="DATOS_DEL_SEGURO/notas"
          (continuar)="continuarNotas()">
          <form [formGroup]="nota">
            <app-campo-texto [control]="nota.controls.texto" etiqueta="Texto de la nota" />
          </form>
        </app-seccion>
      </app-caja>
    }
  `,
  styles: `
    .formulario {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
    }
    .tabla {
      width: 100%;
      border-collapse: collapse;
    }
    .tabla th,
    .tabla td {
      padding: 4px 6px;
      text-align: left;
      border-bottom: 1px solid #ddd;
    }
    .num {
      width: 90px;
    }
    .suma {
      margin-top: 8px;
      font-size: 0.9em;
      color: #555;
    }
    .migas {
      color: #777;
      font-size: 0.85em;
      margin-bottom: 8px;
    }
  `,
})
export class CapturaDatosSolicitudContainer implements OnInit {
  private readonly store = inject(SesionStore);
  private readonly fb = inject(FormBuilder);

  readonly tiposDuracion = TIPOS_DURACION;
  readonly tiposBeneficiario = TIPOS_BENEFICIARIO;
  readonly avisos = this.store.avisos;
  readonly ampliada = signal(false);
  readonly expandida = signal<string>('productores');
  readonly validas = signal<Record<string, boolean>>({});
  readonly opcionSel = signal<boolean[]>([]);
  readonly importes = signal<Record<string, Record<string, number | undefined>>>({});

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
    () =>
      (this.producto()?.['opcionesInversion'] ?? []) as {
        investmentPreferenceCode: string;
        descripcion: string;
        seleccionada?: boolean;
      }[]
  );
  readonly garantias = computed(
    () =>
      ((this.estado() as Record<string, unknown> | undefined)?.['garantias'] ?? []) as {
        codigo: string;
        descripcion: string;
        obligatoria: boolean;
        seleccionada?: boolean;
      }[]
  );
  readonly periodicidadesProducto = computed(() => {
    const codigos = this.producto()?.['periodicidades'] as string[] | undefined;
    return PERIODICIDADES.filter(p => !codigos || codigos.includes(p.valor));
  });
  readonly requierePrestaciones = computed(() => !!this.domiciliaciones.value.requierePrestaciones);

  readonly productores = this.fb.nonNullable.group({
    oficina: ['', Validators.required],
    productor: ['', Validators.required],
    comisionMaxima: [null as number | null],
    comisionDeseada: [null as number | null],
    aportacionPlanificada: [false],
    aportacionExtraordinaria: [false],
  });

  readonly operacion = this.fb.nonNullable.group({
    fechaEfecto: [new Date().toISOString().slice(0, 10), Validators.required],
    tipoDuracion: ['ANIOS', Validators.required],
    duracion: [null as number | null],
    tabla: [''],
    edadVencimiento: [null as number | null],
    fechaVencimiento: [''],
    primaUnica: [null as number | null],
    aportacionPeriodica: [null as number | null],
    periodicidad: [''],
    diaCobro: [null as number | null],
    revalorizacion: [false],
    porcentajeCrecimiento: [null as number | null],
    reinversionActiva: [false],
    reinversionOperacion: [''],
    reinversionPoliza: [''],
    reinversionTipo: [''],
    gradoMinusvalia: [null as number | null],
    fechaAltaMinusvalia: [''],
  });

  readonly domiciliaciones = this.fb.nonNullable.group({
    ibanRecibos: [
      '',
      [
        Validators.required,
        (c: { value: string }) => (c.value && !esIbanValido(c.value) ? { iban: true } : null),
      ],
    ],
    ibanPrestaciones: [''],
    requierePrestaciones: [false],
  });

  readonly datosContacto = this.fb.nonNullable.group({
    tipoDireccion: ['CORRESPONDENCIA'],
    tipoVia: [''],
    nombreVia: [''],
    numero: [''],
    codigoPostal: [''],
    localidad: [''],
    provincia: [''],
    pais: ['ES'],
  });

  readonly asegurado = this.fb.nonNullable.group({
    esTomador: [true],
    nombre: [''],
    primerApellido: [''],
    fechaNacimiento: [''],
    sexo: [''],
    parentesco: [''],
  });

  readonly beneficiarios = this.fb.nonNullable.group({
    tipo: ['HEREDEROS'],
    textoLibre: [''],
  });

  readonly nota = this.fb.nonNullable.group({ texto: [''] });

  ngOnInit(): void {
    const est = this.estado();
    const e = est as Record<string, unknown> | undefined;
    if (e?.['datosProductores']) this.productores.patchValue(e['datosProductores'] as never);
    if (e?.['datosOperacion']) this.operacion.patchValue(e['datosOperacion'] as never);
    if (e?.['domiciliaciones']) this.domiciliaciones.patchValue(e['domiciliaciones'] as never);
    if (e?.['datosContacto']) this.datosContacto.patchValue(e['datosContacto'] as never);
    if (e?.['asegurado']) this.asegurado.patchValue(e['asegurado'] as never);
    if (e?.['beneficiarios']) this.beneficiarios.patchValue(e['beneficiarios'] as never);
    const sel = ((e?.['ventaInformada'] as Record<string, unknown> | undefined)?.[
      'opcionesInversion'
    ] ?? []) as { seleccionada?: boolean }[];
    this.opcionSel.set(this.opcionesProducto().map((_, i) => sel[i]?.seleccionada ?? false));
    const imp: Record<string, Record<string, number | undefined>> = {};
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

  seccionValida(cajaId: string, seccionId: string): boolean {
    const key = `${cajaId}/${seccionId}`;
    if (key in this.validas()) return this.validas()[key];
    const caja = (this.estado()?.cajas ?? []).find(c => c.id === cajaId);
    return caja?.secciones.find(s => s.id === seccionId)?.datosValidos ?? false;
  }

  private _post(cajaId: string, seccionId: string, datos: unknown, siguiente?: string): void {
    this.store
      .validarSeccion(cajaId, seccionId, datos as Record<string, unknown>)
      .subscribe(res => {
        const ref = `${cajaId}/${seccionId}`;
        const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
        this.validas.update(v => ({ ...v, [ref]: !hayErrores }));
        if (!hayErrores && siguiente !== undefined) this.expandida.set(siguiente);
      });
  }

  continuarSeccion(seccionId: string, form: { getRawValue(): Record<string, unknown> }): void {
    this._post('DATOS_DEL_SEGURO', seccionId, form.getRawValue(), '');
  }

  continuarProductores(): void {
    this._post('DATOS_PRODUCTORES', 'productores', this.productores.getRawValue(), 'operacion');
  }

  seleccionarOpcion(i: number, sel: boolean): void {
    this.opcionSel.update(v => v.map((b, j) => (j === i ? sel : b)));
    if (sel && this.opcionesProducto().length && !this.importes()[i]?.['unica']) {
      // primera selección: auto-asignar el importe de la prima única
      const prima = this.operacion.value.primaUnica;
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

  importe(i: number, campo: 'unica' | 'periodica' | 'plazo'): number | string {
    return this.importes()[i]?.[campo] ?? '';
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
      primaUnica: this.importes()[i]?.['unica'],
      primaPeriodica: this.importes()[i]?.['periodica'],
      plazoObjetivo: this.importes()[i]?.['plazo'],
    }));
    this._post('DATOS_DEL_SEGURO', 'opcionesInversion', opciones, 'garantias');
  }

  toggleGarantia(i: number, sel: boolean): void {
    const est = this.estado();
    const garantias = (
      (est?.garantias ?? []) as {
        codigo: string;
        descripcion: string;
        obligatoria: boolean;
        seleccionada?: boolean;
      }[]
    ).map((g, j) => (j === i ? { ...g, seleccionada: sel } : g));
    (est as Record<string, unknown>)['garantias'] = garantias;
  }

  continuarGarantias(): void {
    this._post('DATOS_DEL_SEGURO', 'garantias', this.garantias(), 'domiciliaciones');
  }

  continuarAsegurado(): void {
    this._post('DATOS_DEL_SEGURO', 'asegurado', this.asegurado.getRawValue(), '');
  }

  continuarNotas(): void {
    const texto = this.nota.value.texto;
    const notas = texto ? [{ texto, seleccionada: true }] : [];
    this._post('DATOS_DEL_SEGURO', 'notas', notas, '');
  }
}
