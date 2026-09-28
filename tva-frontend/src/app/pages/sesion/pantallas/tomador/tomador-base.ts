/** Base compartida para captura de tomadores (cajas TVA_Caja_Tomador_N). */
import { Directive, OnInit, computed, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup } from '@angular/forms';

import {
  Caja,
  ObtenerCatalogoUsecase,
  PopupAppian,
  SesionStore,
  ValidarSeccionUsecase,
  crearFormulariosTomador,
} from '@tva/core';
import { AppianPopupService } from '../../../ui/appian/appian-popup.service';
import { Opcion } from '../../../ui/campo-select.component';
import { RequisitoTomador } from './tomador-form.component';

@Directive()
export abstract class TomadorBase implements OnInit {
  protected readonly store = inject(SesionStore);
  protected readonly fb = inject(FormBuilder);
  protected readonly popups = inject(AppianPopupService);
  private readonly obtenerCatalogo = inject(ObtenerCatalogoUsecase);
  private readonly validarSeccion = inject(ValidarSeccionUsecase);

  /** Id de la caja del tomador (CAPTURA_DATOS_TOMADOR1/2). */
  abstract readonly cajaId: string;
  abstract readonly indiceTomador: number;

  readonly formularios = crearFormulariosTomador(this.fb.nonNullable);
  readonly datosPersonales = this.formularios.datosPersonales;
  readonly domicilioHabitual = this.formularios.domicilioHabitual;
  readonly mediosContacto = this.formularios.mediosContacto;
  readonly correo = this.formularios.correo;
  readonly fatcaCrs = this.formularios.fatcaCrs;
  readonly legalRepresentative = this.formularios.legalRepresentative;

  readonly hayRepresentante = signal(false);

  /** Catálogos desde /catalogos/<nombre>/ (signals por catálogo). */
  readonly catalogos = signal<Record<string, Opcion[]>>({});

  /** Secciones plegadas/validas marcadas localmente tras cada validar-seccion OK. */
  readonly validas = signal<Record<string, boolean>>({});
  readonly expandida = signal<string>('datosPersonales');

  readonly avisos = this.store.avisos;
  readonly tomador = computed(
    () => (this.store.sesion()?.estado?.tomadores ?? [])[this.indiceTomador]
  );
  readonly caja = computed<Caja | null>(
    () => (this.store.sesion()?.estado?.cajas ?? []).find(c => c.id === this.cajaId) ?? null
  );

  seccionValida(id: string): boolean {
    const sec = this.caja()?.secciones.find(s => s.id === id);
    return this.validas()[id] ?? sec?.datosValidos ?? false;
  }

  /** Validez por sección para la plantilla (local + datosValidos del backend). */
  readonly validez = computed(() => ({
    datosPersonales: this.seccionValida('datosPersonales'),
    domicilioHabitual: this.seccionValida('domicilioHabitual'),
    mediosContacto: this.seccionValida('mediosContacto'),
    fatcaCrs: this.seccionValida('fatcaCrs'),
    legalRepresentative: this.seccionValida('legalRepresentative'),
  }));

  ngOnInit(): void {
    for (const nombre of [
      'sexos',
      'nacionalidades',
      'paises',
      'tiposVia',
      'actividades',
      'sectores',
      'profesiones',
      'provincias',
      'tiposMedioContacto',
    ]) {
      this.obtenerCatalogo.execute(nombre).subscribe(r => {
        this.catalogos.update(c => ({
          ...c,
          [nombre]: r.valores.map(v => ({ valor: v.codigo, etiqueta: v.descripcion })),
        }));
      });
    }
    const t = this.tomador();
    if (t?.datosPersonales) this.datosPersonales.patchValue(t.datosPersonales as never);
    if (t?.domicilioHabitual) this.domicilioHabitual.patchValue(t.domicilioHabitual as never);
    this.fatcaCrs.patchValue((t?.fatcaCrs ?? {}) as never);
    if (t?.legalRepresentative) {
      this.hayRepresentante.set(true);
      this.legalRepresentative.patchValue(t.legalRepresentative as never);
    }
  }

  /** Envía una sección al backend (validar-seccion) y plegado Appian. */
  continuar(seccionId: string, form: FormGroup, datosExtra: Record<string, unknown> = {}): void {
    const datos = { ...form.getRawValue(), ...datosExtra };
    this.validarSeccion.execute(this.cajaId, seccionId, datos).subscribe(res => {
      const ref = `${this.cajaId}/${seccionId}`;
      const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
      this.validas.update(v => ({ ...v, [seccionId]: !hayErrores }));
      if (!hayErrores) {
        const orden = [
          'datosPersonales',
          'domicilioHabitual',
          'mediosContacto',
          'fatcaCrs',
          'legalRepresentative',
        ];
        const siguiente = orden.find(id => id !== seccionId && !this.seccionValida(id));
        this.expandida.set(siguiente ?? '');
      }
    });
  }

  continuarMedios(): void {
    const t = this.tomador();
    const medios = [
      ...(t?.mediosContacto ?? []),
      {
        tipo: this.mediosContacto.value.tipo,
        prefijo: this.mediosContacto.value.prefijo,
        numero: this.mediosContacto.value.numero,
        contactMethodValue: this.mediosContacto.value.numero,
      },
      { tipo: 'EMAIL', contactMethodValue: this.correo.value.contactMethodValue },
    ];
    this.validarSeccion.execute(this.cajaId, 'mediosContacto', medios as never).subscribe(res => {
      const ref = `${this.cajaId}/mediosContacto`;
      const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
      this.validas.update(v => ({ ...v, mediosContacto: !hayErrores }));
      if (!hayErrores) this.expandida.set('fatcaCrs');
    });
  }

  continuarFatca(): void {
    this.continuar('fatcaCrs', this.fatcaCrs);
  }

  continuarRepresentante(): void {
    const datos = this.hayRepresentante() ? this.legalRepresentative.getRawValue() : null;
    this.validarSeccion
      .execute(this.cajaId, 'legalRepresentative', { legalRepresentative: datos } as never)
      .subscribe(res => {
        const ref = `${this.cajaId}/legalRepresentative`;
        const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
        this.validas.update(v => ({ ...v, legalRepresentative: !hayErrores }));
      });
  }

  /** Despacha el Continuar de cada sección emitido por app-tomador-form. */
  onContinuar(seccionId: string): void {
    switch (seccionId) {
      case 'datosPersonales':
        this.continuar('datosPersonales', this.datosPersonales);
        break;
      case 'domicilioHabitual':
        this.continuar('domicilioHabitual', this.domicilioHabitual);
        break;
      case 'mediosContacto':
        this.continuarMedios();
        break;
      case 'fatcaCrs':
        this.continuarFatca();
        break;
      case 'legalRepresentative':
        this.continuarRepresentante();
        break;
    }
  }

  onRequisito(r: RequisitoTomador): void {
    this.abrirRequisito(r.popup, r.etiqueta);
  }

  /** Panel derecho — requisitos del tomador (pop-ups Appian Embedded). */
  readonly requisitos = computed((): RequisitoTomador[] => {
    const t = this.tomador();
    const g = t?.datosGestionParticipante ?? {};
    const tc = t?.perfilCliente?.testConveniencia?.estado;
    const datosOk = this.seccionValida('datosPersonales');
    const mediosOk = this.seccionValida('mediosContacto');
    return [
      {
        etiqueta: 'Consentimiento RGPD',
        popup: 'rgpd',
        hecho: !!g.consentimientoProteccionDatos,
        habilitado: datosOk,
      },
      {
        etiqueta: 'Digitalizar NIF / NIE',
        popup: 'dni',
        hecho: !!g.documentoIdDigitalizado,
        habilitado: datosOk,
      },
      {
        etiqueta: 'Realizar test de conveniencia',
        popup: 'test-conveniencia',
        hecho: tc === 'FIRMADO' || !!g.testConvenienciaVigente,
        habilitado: datosOk && mediosOk,
      },
    ];
  });

  abrirRequisito(popup: PopupAppian, etiqueta: string): void {
    if (!this.store.claveSesion()) return;
    this.popups.abrir(popup, this.indiceTomador, etiqueta).subscribe({
      error: () => undefined,
    });
  }
}
