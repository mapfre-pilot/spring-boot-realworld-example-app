/** Factories de Reactive Forms de la solicitud (validadores centralizados). */
import { AbstractControl, NonNullableFormBuilder, Validators } from '@angular/forms';

import { esIbanValido } from '../../domain/validaciones/documentos';

export function crearFormulariosSolicitud(fb: NonNullableFormBuilder) {
  return {
    productores: fb.group({
      oficina: ['', Validators.required],
      productor: ['', Validators.required],
      comisionMaxima: [null as number | null],
      comisionDeseada: [null as number | null],
      aportacionPlanificada: [false],
      aportacionExtraordinaria: [false],
    }),
    operacion: fb.group({
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
    }),
    domiciliaciones: fb.group({
      ibanRecibos: [
        '',
        [
          Validators.required,
          (c: AbstractControl) => (c.value && !esIbanValido(c.value) ? { iban: true } : null),
        ],
      ],
      ibanPrestaciones: [''],
      requierePrestaciones: [false],
    }),
    datosContacto: fb.group({
      tipoDireccion: ['CORRESPONDENCIA'],
      tipoVia: [''],
      nombreVia: [''],
      numero: [''],
      codigoPostal: [''],
      localidad: [''],
      provincia: [''],
      pais: ['ES'],
    }),
    asegurado: fb.group({
      esTomador: [true],
      nombre: [''],
      primerApellido: [''],
      fechaNacimiento: [''],
      sexo: [''],
      parentesco: [''],
    }),
    beneficiarios: fb.group({
      tipo: ['HEREDEROS'],
      textoLibre: [''],
    }),
    nota: fb.group({ texto: [''] }),
  };
}

export type FormulariosSolicitud = ReturnType<typeof crearFormulariosSolicitud>;
