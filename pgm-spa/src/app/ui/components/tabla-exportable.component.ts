import { Component, computed, input, output, signal } from '@angular/core';
import { IconoComponent } from './icono.component';

export interface Columna<T> {
  clave: keyof T & string;
  titulo: string;
  formato?: (valor: unknown, fila: T) => string;
  /** Clase CSS de la celda (p. ej. 'badge', 'pill-estado'): el valor se pinta como etiqueta. */
  etiqueta?: (valor: unknown, fila: T) => string;
}

/** Exporta filas a CSV en el navegador (separador ';', BOM UTF-8 para Excel); no envía datos a terceros. */
export function exportarCsv(nombre: string, cabeceras: string[], filas: string[][]): void {
  const esc = (s: string) => `"${s.replace(/"/g, '""')}"`;
  const lineas = [cabeceras.map(esc).join(';'), ...filas.map((f) => f.map(esc).join(';'))];
  const blob = new Blob(['\uFEFF' + lineas.join('\r\n')], { type: 'text/csv;charset=utf-8' });
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob);
  a.download = `${nombre}.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
}

/** Tabla ordenable con exportación CSV y navegación opcional por fila. */
@Component({
  selector: 'pgm-tabla-exportable',
  imports: [IconoComponent],
  template: `
    <div class="row cabecera-tabla">
      <span class="titulo"
        ><strong>{{ titulo() }}</strong> ({{ filasOrdenadas().length }})</span
      >
      <span class="spacer"></span>
      <button class="btn-enlace" [disabled]="!filas().length" (click)="exportar()">
        Descargar <pgm-icono nombre="descargar" [tam]="17" />
      </button>
    </div>
    @if (filas().length) {
      <table class="tabla">
        <thead>
          <tr>
            @for (c of columnas(); track c.clave) {
              <th (click)="ordenarPor(c.clave)">
                {{ c.titulo }}
                @if (orden().clave === c.clave) {
                  <span>{{ orden().asc ? '▲' : '▼' }}</span>
                }
              </th>
            }
            @if (navegable()) {
              <th aria-label="Abrir"></th>
            }
          </tr>
        </thead>
        <tbody>
          @for (f of filasOrdenadas(); track $index) {
            <tr
              [class.navegable]="navegable()"
              [attr.tabindex]="navegable() ? 0 : null"
              (click)="abrir(f)"
              (keydown.enter)="abrir(f)"
            >
              @for (c of columnas(); track c.clave) {
                <td>
                  @if (c.etiqueta) {
                    <span [class]="c.etiqueta(celda(f, c), f)">{{ valor(c, f) }}</span>
                  } @else {
                    {{ valor(c, f) }}
                  }
                </td>
              }
              @if (navegable()) {
                <td class="flecha"><pgm-icono nombre="derecha" [trazo]="2.4" /></td>
              }
            </tr>
          }
        </tbody>
      </table>
    } @else {
      <div class="vacio">{{ mensajeVacio() }}</div>
    }
  `,
  styles: `
    .cabecera-tabla {
      padding: 0.25rem 0 0.75rem;
    }
    .titulo {
      font-size: 1.05rem;
    }
    .flecha {
      color: var(--pgm-rojo);
      width: 32px;
    }
  `,
})
export class TablaExportableComponent<T extends object> {
  readonly titulo = input('');
  readonly columnas = input.required<Columna<T>[]>();
  readonly filas = input.required<T[]>();
  readonly mensajeVacio = input('Sin elementos');
  readonly nombreFichero = input('export');
  readonly navegable = input(false);
  readonly filaSeleccionada = output<T>();
  readonly orden = signal<{ clave: string | null; asc: boolean }>({ clave: null, asc: true });

  readonly filasOrdenadas = computed(() => {
    const { clave, asc } = this.orden();
    const filas = [...this.filas()];
    if (!clave) return filas;
    return filas.sort((a, b) => {
      const va = (a as Record<string, unknown>)[clave];
      const vb = (b as Record<string, unknown>)[clave];
      const r = `${va ?? ''}`.localeCompare(`${vb ?? ''}`, 'es', { numeric: true });
      return asc ? r : -r;
    });
  });

  ordenarPor(clave: string): void {
    const o = this.orden();
    this.orden.set({ clave, asc: o.clave === clave ? !o.asc : true });
  }

  abrir(f: T): void {
    if (this.navegable()) this.filaSeleccionada.emit(f);
  }

  celda(f: T, c: Columna<T>): unknown {
    return (f as Record<string, unknown>)[c.clave];
  }

  valor(c: Columna<T>, f: T): string {
    const v = this.celda(f, c);
    return c.formato ? c.formato(v, f) : `${v ?? ''}`;
  }

  exportar(): void {
    const cols = this.columnas();
    exportarCsv(
      this.nombreFichero(),
      cols.map((c) => c.titulo),
      this.filasOrdenadas().map((f) => cols.map((c) => this.valor(c, f))),
    );
  }
}
