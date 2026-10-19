import { Component, computed, input, signal } from '@angular/core';

export interface Columna<T> {
  clave: keyof T & string;
  titulo: string;
  formato?: (valor: unknown, fila: T) => string;
}

/** Tabla ordenable con exportación CSV en cliente (sin enviar datos a ningún tercero). */
@Component({
  selector: 'pgm-tabla-exportable',
  template: `
    <div class="row cabecera-tabla">
      <strong>{{ titulo() }}</strong>
      <span class="muted">{{ filasOrdenadas().length }} elementos</span>
      <span class="spacer"></span>
      <button class="btn btn-secundario" [disabled]="!filas().length" (click)="exportar()">Exportar CSV</button>
    </div>
    @if (filas().length) {
      <table class="tabla">
        <thead>
          <tr>
            @for (c of columnas(); track c.clave) {
              <th (click)="ordenarPor(c.clave)">
                {{ c.titulo }}
                @if (orden().clave === c.clave) { <span>{{ orden().asc ? '▲' : '▼' }}</span> }
              </th>
            }
          </tr>
        </thead>
        <tbody>
          @for (f of filasOrdenadas(); track $index) {
            <tr>
              @for (c of columnas(); track c.clave) {
                <td>{{ valor(c, f) }}</td>
              }
            </tr>
          }
        </tbody>
      </table>
    } @else {
      <div class="vacio">{{ mensajeVacio() }}</div>
    }
  `,
  styles: `.cabecera-tabla { margin-bottom: .5rem; }`,
})
export class TablaExportableComponent<T extends object> {
  readonly titulo = input('');
  readonly columnas = input.required<Columna<T>[]>();
  readonly filas = input.required<T[]>();
  readonly mensajeVacio = input('Sin elementos');
  readonly nombreFichero = input('export');
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

  valor(c: Columna<T>, f: T): string {
    const v = (f as Record<string, unknown>)[c.clave];
    return c.formato ? c.formato(v, f) : `${v ?? ''}`;
  }

  exportar(): void {
    const cols = this.columnas();
    const esc = (s: string) => `"${s.replace(/"/g, '""')}"`;
    const lineas = [
      cols.map((c) => esc(c.titulo)).join(';'),
      ...this.filasOrdenadas().map((f) => cols.map((c) => esc(this.valor(c, f))).join(';')),
    ];
    const blob = new Blob(['\uFEFF' + lineas.join('\r\n')], { type: 'text/csv;charset=utf-8' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `${this.nombreFichero()}.csv`;
    a.click();
    URL.revokeObjectURL(a.href);
  }
}
