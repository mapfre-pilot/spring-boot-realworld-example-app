import { Component, input } from '@angular/core';

/** Estado de carga / error uniforme para páginas (errores RFC 9457 del BFF). */
@Component({
  selector: 'pgm-estado',
  template: `
    @if (cargando()) { <div class="vacio">Cargando…</div> }
    @if (error()) { <div class="alerta alerta-error">{{ error() }}</div> }
  `,
})
export class EstadoComponent {
  readonly cargando = input(false);
  readonly error = input<string | null>(null);
}
