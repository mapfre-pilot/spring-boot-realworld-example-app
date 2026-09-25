/** Factories de Reactive Forms del tomador (validadores centralizados). */
import { AbstractControl, NonNullableFormBuilder, Validators } from '@angular/forms';

import { esDocumentoIdentidadValido } from '../../domain/validaciones/documentos';

export function crearFormulariosTomador(fb: NonNullableFormBuilder) {
  return {
    datosPersonales: fb.group({
      documentId: [
        '',
        [
          Validators.required,
          (c: AbstractControl) =>
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
    }),
    domicilioHabitual: fb.group({
      tipoVia: ['', Validators.required],
      nombreVia: ['', Validators.required],
      numero: ['', Validators.required],
      complementoDireccion: [''],
      codigoPostal: ['', [Validators.required, Validators.pattern(/^\d{5}$/)]],
      localidad: ['', Validators.required],
      provincia: ['', Validators.required],
      pais: ['ES', Validators.required],
    }),
    mediosContacto: fb.group({
      tipo: ['MOVIL', Validators.required],
      prefijo: ['+34', Validators.required],
      numero: ['', [Validators.required, Validators.pattern(/^\d{9}$/)]],
      contactMethodValue: [''],
    }),
    correo: fb.group({
      contactMethodValue: ['', [Validators.required, Validators.email]],
    }),
    fatcaCrs: fb.group({
      residenteFiscalOtroPais: [false],
    }),
    legalRepresentative: fb.group({
      documentId: [''],
      nombre: [''],
      primerApellido: [''],
      sexo: [''],
      fechaNacimiento: [''],
      parentesco: [''],
    }),
  };
}

export type FormulariosTomador = ReturnType<typeof crearFormulariosTomador>;
