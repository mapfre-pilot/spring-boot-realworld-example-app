/** Constantes de presentación de captura-datos-solicitud. */
import { Opcion } from '../../../../shared/ui/formularios/campo-select/campo-select.component';

export const TIPOS_DURACION: Opcion[] = [
  { valor: 'ANIOS', etiqueta: 'Años' },
  { valor: 'TABLA', etiqueta: 'Tabla' },
  { valor: 'EDAD_VENCIMIENTO', etiqueta: 'Edad de vencimiento' },
  { valor: 'FECHA_VENCIMIENTO', etiqueta: 'Fecha de vencimiento' },
  { valor: 'JUBILACION', etiqueta: 'Jubilación' },
];

export const TIPOS_BENEFICIARIO: Opcion[] = [
  { valor: 'HEREDEROS', etiqueta: 'Herederos legales' },
  { valor: 'HIJOS', etiqueta: 'Hijos' },
  { valor: 'PADRES', etiqueta: 'Padres' },
  { valor: 'CONYUGE', etiqueta: 'Cónyuge' },
  { valor: 'TOMADOR', etiqueta: 'Tomador' },
  { valor: 'HERMANOS', etiqueta: 'Hermanos' },
  { valor: 'TEXTO_LIBRE', etiqueta: 'Texto libre' },
];

export const PERIODICIDADES: Opcion[] = [
  { valor: 'M', etiqueta: 'Mensual' },
  { valor: 'T', etiqueta: 'Trimestral' },
  { valor: 'S', etiqueta: 'Semestral' },
  { valor: 'A', etiqueta: 'Anual' },
];

export const SECCIONES: [string, string][] = [
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
