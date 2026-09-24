/** Base compartida para captura de tomadores (campos de TVA_CapturaTomador_*). */
import { Directive, inject } from '@angular/core';
import { FormBuilder, Validators } from '@angular/forms';

import { SesionStore } from '../../../core/state/sesion.store';
import { esDocumentoIdentidadValido, esIbanValido } from '../../../core/validaciones/documentos';
import { Opcion } from '../../../shared/ui/campo-select.component';

export const TIPOS_DOCUMENTO: Opcion[] = [
  { valor: 'NIF', etiqueta: 'NIF' },
  { valor: 'NIE', etiqueta: 'NIE' },
  { valor: 'CIF', etiqueta: 'CIF' },
];

export const SEXOS: Opcion[] = [
  { valor: 'H', etiqueta: 'Hombre' },
  { valor: 'M', etiqueta: 'Mujer' },
];

export const ESTADOS_CIVILES: Opcion[] = [
  { valor: 'SOLTERO', etiqueta: 'Soltero/a' },
  { valor: 'CASADO', etiqueta: 'Casado/a' },
  { valor: 'VIUDO', etiqueta: 'Viudo/a' },
  { valor: 'DIVORCIADO', etiqueta: 'Divorciado/a' },
];

export const TIPOS_BENEFICIARIO: Opcion[] = [
  { valor: 'ESTANDAR', etiqueta: 'Cláusula estándar (herederos legales)' },
  { valor: 'PERSONAS', etiqueta: 'Personas concretas' },
  { valor: 'TEXTO_LIBRE', etiqueta: 'Texto libre' },
];

@Directive()
export abstract class TomadorBase {
  protected readonly store = inject(SesionStore);

  readonly tiposDocumento = TIPOS_DOCUMENTO;
  readonly sexos = SEXOS;
  readonly estadosCiviles = ESTADOS_CIVILES;
  readonly tiposBeneficiario = TIPOS_BENEFICIARIO;

  readonly form = inject(FormBuilder).nonNullable.group({
    tipoDocumento: ['NIF', Validators.required],
    documento: [
      '',
      [
        Validators.required,
        (c: import('@angular/forms').AbstractControl) =>
          esDocumentoIdentidadValido(c.value) ? null : { documento: true },
      ],
    ],
    nombre: ['', Validators.required],
    apellido1: ['', Validators.required],
    apellido2: [''],
    fechaNacimiento: ['', Validators.required],
    sexo: ['H', Validators.required],
    estadoCivil: ['CASADO', Validators.required],
    tipoVia: ['CALLE', Validators.required],
    direccion: ['', Validators.required],
    codigoPostal: ['', [Validators.required, Validators.pattern(/^\d{5}$/)]],
    poblacion: ['', Validators.required],
    provincia: ['', Validators.required],
    telefono: ['', [Validators.required, Validators.pattern(/^\d{9}$/)]],
    email: ['', [Validators.required, Validators.email]],
    iban: [
      '',
      [
        Validators.required,
        (c: import('@angular/forms').AbstractControl) =>
          esIbanValido(c.value) ? null : { iban: true },
      ],
    ],
    tipoBeneficiario: ['ESTANDAR', Validators.required],
    beneficiarios: [''],
  });

  continuar(): void {
    this.store.ejecutar('continuar-tomador', { tomador: this.form.getRawValue() }).subscribe();
  }

  anterior(): void {
    this.store.ejecutar('anterior').subscribe();
  }
}
