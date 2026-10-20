import { Component, computed, input } from '@angular/core';

/** Iconos de trazo (SVG en línea, sin dependencias externas): equivalente propio de la iconografía de PGM en Appian. */
export const ICONOS = {
  buscar: ['M11 4a7 7 0 1 1 0 14 7 7 0 0 1 0-14z', 'M21 21l-5-5'],
  telefono: [
    'M22 16.9v3a2 2 0 0 1-2.2 2 19.8 19.8 0 0 1-8.6-3.1 19.5 19.5 0 0 1-6-6A19.8 19.8 0 0 1 2.1 4.2 2 2 0 0 1 4.1 2h3a2 2 0 0 1 2 1.7c.1.9.4 1.8.7 2.7a2 2 0 0 1-.5 2.1L8 9.8a16 16 0 0 0 6 6l1.3-1.3a2 2 0 0 1 2.1-.4c.9.3 1.8.6 2.7.7a2 2 0 0 1 1.7 2z',
  ],
  email: ['M3 6h18v12H3z', 'M3 6l9 7 9-7'],
  campana: ['M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9', 'M13.7 21a2 2 0 0 1-3.4 0'],
  refrescar: ['M21 12a9 9 0 1 1-2.6-6.4', 'M21 3v6h-6'],
  mas: ['M12 5v14', 'M5 12h14'],
  aviso: [
    'M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z',
    'M12 9v4',
    'M12 17h.01',
  ],
  externo: ['M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6', 'M15 3h6v6', 'M10 14 21 3'],
  derecha: ['M9 18l6-6-6-6'],
  izquierda: ['M15 18l-6-6 6-6'],
  abajo: ['M6 9l6 6 6-6'],
  descargar: ['M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4', 'M7 10l5 5 5-5', 'M12 15V3'],
  vida: [
    'M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z',
  ],
  autos: [
    'M5 17h14v-5l-2-5H7l-2 5z',
    'M3 12h18',
    'M7 17v2',
    'M17 17v2',
    'M7.5 14.5h.01',
    'M16.5 14.5h.01',
  ],
  hogar: ['M3 11l9-8 9 8', 'M5 10v10h14V10', 'M10 20v-6h4v6'],
  salud: ['M9 3h6v6h6v6h-6v6H9v-6H3V9h6z'],
  ahorro: [
    'M12 3c4.4 0 8 1.3 8 3s-3.6 3-8 3-8-1.3-8-3 3.6-3 8-3z',
    'M4 6v6c0 1.7 3.6 3 8 3s8-1.3 8-3V6',
    'M4 12v6c0 1.7 3.6 3 8 3s8-1.3 8-3v-6',
  ],
  decesos: [
    'M12 7a3 3 0 1 0 0 6 3 3 0 0 0 0-6z',
    'M12 13v8',
    'M12 18c-2.5 0-4.5-1.5-5-3.5',
    'M12 2v2',
    'M6 10H4',
    'M20 10h-2',
  ],
  empresas: [
    'M3 21h18',
    'M5 21V7l7-4 7 4v14',
    'M9 9h.01',
    'M15 9h.01',
    'M9 13h.01',
    'M15 13h.01',
    'M10 21v-4h4v4',
  ],
  otros: ['M21 8l-9-5-9 5 9 5 9-5z', 'M3 8v8l9 5 9-5V8', 'M12 13v8'],
  usuario: ['M20 21a8 8 0 0 0-16 0', 'M12 3a4 4 0 1 1 0 8 4 4 0 0 1 0-8z'],
  info: ['M12 2a10 10 0 1 1 0 20 10 10 0 0 1 0-20z', 'M12 16v-4', 'M12 8h.01'],
  check: ['M20 6 9 17l-5-5'],
  cerrar: ['M18 6 6 18', 'M6 6l12 12'],
  documento: ['M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z', 'M14 2v6h6'],
  salir: ['M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4', 'M16 17l5-5-5-5', 'M21 12H9'],
} as const;

export type NombreIcono = keyof typeof ICONOS;

@Component({
  selector: 'pgm-icono',
  template: `
    <svg
      [attr.width]="tam()"
      [attr.height]="tam()"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      [attr.stroke-width]="trazo()"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      @for (d of trazos(); track $index) {
        <path [attr.d]="d" />
      }
    </svg>
  `,
  styles: `
    :host {
      display: inline-flex;
      vertical-align: middle;
      line-height: 0;
    }
  `,
})
export class IconoComponent {
  readonly nombre = input.required<NombreIcono>();
  readonly tam = input(18);
  readonly trazo = input(1.8);
  readonly trazos = computed(() => ICONOS[this.nombre()]);
}
