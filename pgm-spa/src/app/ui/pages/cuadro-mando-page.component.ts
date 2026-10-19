import { DecimalPipe } from '@angular/common';
import { Component, inject, signal } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { Kpi } from '../../domain/models/api.models';
import { EstadoComponent } from '../components/estado.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/** /cuadro-mando — KPIs de uso y gestión (visibilidad PGM_VISUALIZAR_CDM). */
@Component({
  selector: 'pgm-cuadro-mando-page',
  imports: [DecimalPipe, EstadoComponent, TablaExportableComponent],
  template: `
    <section class="card">
      <h1>Cuadro de mando</h1>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
      <div class="grid grid-4">
        @for (k of kpis(); track k.codigo) {
          <article class="card kpi">
            <div class="valor">{{ k.valor | number: '1.0-2' }}<small> {{ k.unidad }}</small></div>
            <div>{{ k.nombre }}</div>
            <div class="muted">{{ k.periodo }}</div>
          </article>
        }
      </div>
    </section>
    <section class="card">
      <pgm-tabla-exportable titulo="Detalle de indicadores" nombreFichero="kpis" [columnas]="columnas" [filas]="kpis()" />
    </section>
  `,
})
export class CuadroMandoPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly kpis = signal<Kpi[]>([]);
  readonly cargando = signal(true);
  readonly error = signal<string | null>(null);
  readonly columnas: Columna<Kpi>[] = [
    { clave: 'codigo', titulo: 'Código' }, { clave: 'nombre', titulo: 'Indicador' }, { clave: 'valor', titulo: 'Valor' }, { clave: 'unidad', titulo: 'Unidad' }, { clave: 'periodo', titulo: 'Periodo' },
  ];

  constructor() {
    void firstValueFrom(this.repo.kpis())
      .then((r) => this.kpis.set(r.items))
      .catch((e: Error) => this.error.set(e.message))
      .finally(() => this.cargando.set(false));
  }
}
