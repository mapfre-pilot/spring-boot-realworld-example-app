/** Constantes de presentación de inicio. */
import { Opcion } from '../../shared/ui/formularios/campo-select.component';

export const MODOS: Opcion[] = [
  { valor: 'VA', etiqueta: 'Venta Asesorada' },
  { valor: 'VIA', etiqueta: 'Venta Informada Ahorro' },
  { valor: 'R2C', etiqueta: 'Rentas' },
];

export const OPERACIONES: Opcion[] = [
  { valor: 'S', etiqueta: 'Suscripción' },
  { valor: 'AE', etiqueta: 'Aportación extraordinaria' },
];

export const FRECUENCIAS: Opcion[] = [
  { valor: 'M', etiqueta: 'Mensual' },
  { valor: 'T', etiqueta: 'Trimestral' },
  { valor: 'S', etiqueta: 'Semestral' },
  { valor: 'A', etiqueta: 'Anual' },
];
