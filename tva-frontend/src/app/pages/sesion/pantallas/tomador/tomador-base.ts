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
import { AppianPopupService } from '../../../../core/infra/appian/appian-popup.service';
import { Opcion } from '../../../../shared/ui/formularios/campo-select.component';
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
  protected readonly domicilioHabitual = this.formularios.domicilioHabitual;
  protected readonly mediosContacto = this.formularios.mediosContacto;
  protected readonly correo = this.formularios.correo;
  protected readonly fatcaCrs = this.formularios.fatcaCrs;
  protected readonly legalRepresentative = this.formularios.legalRepresentative;

  protected readonly hayRepresentante = signal(false);

  /** Catálogos desde /catalogos/<nombre>/ (signals por catálogo). */
  protected readonly catalogos = signal<Record<string, Opcion[]>>({});

  /** Secciones plegadas/validas marcadas localmente tras cada validar-seccion OK. */
  protected readonly validas = signal<Record<string, boolean>>({});
  protected readonly expandida = signal<string>('datosPersonales');

  protected readonly avisos = this.store.avisos;
  protected readonly tomador = computed(
    () => (this.store.sesion()?.estado?.tomadores ?? [])[this.indiceTomador]
  );
  protected readonly caja = computed<Caja | null>(
    () => (this.store.sesion()?.estado?.cajas ?? []).find(c => c.id === this.cajaId) ?? null
  );

  protected seccionValida(id: string): boolean {
    const sec = this.caja()?.secciones.find(s => s.id === id);
    return this.validas()[id] ?? sec?.datosValidos ?? false;
  }

  /** Validez por sección para la plantilla (local + datosValidos del backend). */
  protected readonly validez = computed(() => ({
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

  protected continuarMedios(): void {
    const t = this.tomador();
    const propios = new Set(['MOVIL', 'FIJO', 'OTRO', 'EMAIL']);
    const medios: Record<string, unknown>[] = (
      (Array.isArray(t?.mediosContacto) ? t.mediosContacto : []) as {
        tipo?: string;
      }[]
    ).filter(m => !propios.has(m.tipo ?? '')) as Record<string, unknown>[];
    const numero = this.mediosContacto.value.numero;
    if (numero) {
      medios.push({
        tipo: this.mediosContacto.value.tipo ?? 'MOVIL',
        prefijo: this.mediosContacto.value.prefijo,
        numero,
        contactMethodValue: numero,
      });
    }
    const email = this.correo.value.contactMethodValue;
    if (email) medios.push({ tipo: 'EMAIL', contactMethodValue: email });
    this.validarSeccion.execute(this.cajaId, 'mediosContacto', medios as never).subscribe(res => {
      const ref = `${this.cajaId}/mediosContacto`;
      const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
      this.validas.update(v => ({ ...v, mediosContacto: !hayErrores }));
      if (!hayErrores) this.expandida.set('fatcaCrs');
    });
  }

  protected continuarFatca(): void {
    this.continuar('fatcaCrs', this.fatcaCrs);
  }

  protected continuarRepresentante(): void {
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
  protected onContinuar(seccionId: string): void {
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

  protected onRequisito(r: RequisitoTomador): void {
    this.abrirRequisito(r.popup, r.etiqueta);
  }

  /** Panel derecho — requisitos del tomador (pop-ups Appian Embedded). */
  protected readonly requisitos = computed((): RequisitoTomador[] => {
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

  protected abrirRequisito(popup: PopupAppian, etiqueta: string): void {
    if (!this.store.claveSesion()) return;
    this.popups.abrir(popup, this.indiceTomador, etiqueta).subscribe({
      error: () => undefined,
    });
  }
}
