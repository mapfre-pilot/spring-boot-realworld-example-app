/** Pop-ups Appian Embedded (panel de requisitos del tomador). */
export type PopupAppian = 'rgpd' | 'dni' | 'test-conveniencia';
export interface PopupLanzadoResponse {
  popup: PopupAppian;
  idxTomador: number;
  taskId: string;
  taskUrl: string;
  modo: 'mock' | 'real';
}
export type PopupResultado = 'SUBMIT' | 'DISMISS' | 'ERROR';
