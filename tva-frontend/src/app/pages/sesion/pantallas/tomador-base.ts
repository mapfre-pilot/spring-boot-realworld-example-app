/** Base compartida para captura de tomadores (cajas TVA_Caja_Tomador_N). */
import { Directive, OnInit, computed, inject, signal } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';

import { Caja, PopupAppian } from '../../../core/models/models';
import { AppianPopupService } from '../../../core/appian/appian-popup.service';
import { SesionStore } from '../../../core/state/sesion.store';
import { esDocumentoIdentidadValido } from '../../../core/validaciones/documentos';
import { Opcion } from '../../../shared/ui/campo-select.component';

@Directive()
export abstract class TomadorBase implements OnInit {
  protected readonly store = inject(SesionStore);
  protected readonly fb = inject(FormBuilder);
  protected readonly popups = inject(AppianPopupService);

  /** Id de la caja del tomador (CAPTURA_DATOS_TOMADOR1/2). */
  abstract readonly cajaId: string;
  abstract readonly indiceTomador: number;

  readonly datosPersonales = this.fb.nonNullable.group({
    documentId: [
      '',
      [
        Validators.required,
        (c: import('@angular/forms').AbstractControl) =>
          esDocumentoIdentidadValido(c.value) ? null : { documento: true },
      ],
    ],
    nombre: ['', Validators.required],
    primerApellido: ['', Validators.required],
    segundoApellido: [''],
    fechaNacimiento: ['', Validators.required],
    sexo: ['', Validators.required],
    nacionalidad: ['ES', Validators.required],
    paisNacimiento: ['ES', Validators.required],
    actividad: ['', Validators.required],
    sector: ['', Validators.required],
    profesion: ['', Validators.required],
    responsabilidadPublica: [false],
    residenciaHabitualEspanya: [true],
  });

  readonly domicilioHabitual = this.fb.nonNullable.group({
    tipoVia: ['', Validators.required],
    nombreVia: ['', Validators.required],
    numero: ['', Validators.required],
    complementoDireccion: [''],
    codigoPostal: ['', [Validators.required, Validators.pattern(/^\d{5}$/)]],
    localidad: ['', Validators.required],
    provincia: ['', Validators.required],
    pais: ['ES', Validators.required],
  });

  readonly mediosContacto = this.fb.nonNullable.group({
    tipo: ['MOVIL', Validators.required],
    prefijo: ['+34', Validators.required],
    numero: ['', [Validators.required, Validators.pattern(/^\d{9}$/)]],
    contactMethodValue: [''],
  });

  readonly correo = this.fb.nonNullable.group({
    contactMethodValue: ['', [Validators.required, Validators.email]],
  });

  readonly fatcaCrs = this.fb.nonNullable.group({
    residenteFiscalOtroPais: [false],
  });

  readonly hayRepresentante = signal(false);
  readonly legalRepresentative = this.fb.nonNullable.group({
    documentId: [''],
    nombre: [''],
    primerApellido: [''],
    sexo: [''],
    fechaNacimiento: [''],
    parentesco: [''],
  });

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

  ngOnInit(): void {
    const api = (
      this.store as unknown as {
        api: {
          catalogo: (
            n: string
          ) => import('rxjs').Observable<{ valores: { codigo: string; descripcion: string }[] }>;
        };
      }
    ).api;
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
      api.catalogo(nombre).subscribe(r => {
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
    this.store.validarSeccion(this.cajaId, seccionId, datos).subscribe(res => {
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
    this.store.validarSeccion(this.cajaId, 'mediosContacto', medios as never).subscribe(res => {
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
    this.store
      .validarSeccion(this.cajaId, 'legalRepresentative', { legalRepresentative: datos } as never)
      .subscribe(res => {
        const ref = `${this.cajaId}/legalRepresentative`;
        const hayErrores = res.avisos.some(a => a.seccion === ref && a.tipo === 'ERROR');
        this.validas.update(v => ({ ...v, legalRepresentative: !hayErrores }));
      });
  }

  /** Panel derecho — requisitos del tomador (pop-ups Appian Embedded). */
  readonly requisitos = computed(
    (): { etiqueta: string; popup: PopupAppian; hecho: boolean; habilitado: boolean }[] => {
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
    }
  );

  abrirRequisito(popup: PopupAppian, etiqueta: string): void {
    const clave = this.store.claveSesion();
    if (!clave) return;
    this.popups.abrir(clave, popup, this.indiceTomador, etiqueta).subscribe(res => {
      const s = this.store.sesion();
      if (s) {
        this.store.sesion.set({
          ...s,
          pantalla_actual: res.pantallaActual,
          estado: { ...res.estado, avisos: res.avisos },
        });
      }
    });
  }
}
