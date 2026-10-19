import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';
import { TablaExportableComponent } from './tabla-exportable.component';

interface Fila {
  numero: string;
  importe: number;
}

describe('TablaExportableComponent', () => {
  let spectator: Spectator<TablaExportableComponent<Fila>>;
  const createComponent = createComponentFactory<TablaExportableComponent<Fila>>({
    component: TablaExportableComponent,
  });
  const filas: Fila[] = [
    { numero: 'R-2', importe: 20 },
    { numero: 'R-10', importe: 5 },
    { numero: 'R-1', importe: 50 },
  ];
  const columnas = [
    { clave: 'numero' as const, titulo: 'Recibo' },
    { clave: 'importe' as const, titulo: 'Importe', formato: (v: unknown) => `${v} €` },
  ];

  beforeEach(() => {
    spectator = createComponent({ props: { columnas, filas, titulo: 'Recibos' } });
  });

  it('pinta las filas con el formato de columna', () => {
    expect(spectator.queryAll('tbody tr')).toHaveLength(3);
    expect(spectator.query('tbody tr td:nth-child(2)')).toHaveText('20 €');
  });

  it('ordena de forma natural al pulsar la cabecera y alterna el sentido', () => {
    spectator.click('thead th');
    expect(
      spectator.queryAll('tbody tr td:first-child').map((td) => td.textContent?.trim()),
    ).toEqual(['R-1', 'R-2', 'R-10']);
    spectator.click('thead th');
    expect(
      spectator.queryAll('tbody tr td:first-child').map((td) => td.textContent?.trim()),
    ).toEqual(['R-10', 'R-2', 'R-1']);
  });

  it('muestra el mensaje de vacío sin filas', () => {
    spectator.setInput('filas', []);
    expect(spectator.query('.vacio')).toHaveText('Sin elementos');
  });
});
