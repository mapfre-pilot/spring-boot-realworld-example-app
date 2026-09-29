import { createComponentFactory } from '@ngneat/spectator/jest';

import { EstadoVacioComponent } from './estado-vacio.component';

describe('EstadoVacioComponent', () => {
  const create = createComponentFactory({ component: EstadoVacioComponent });

  it('renderiza mensaje e icono', () => {
    const s = create({ props: { mensaje: 'Sin datos', icono: 'inbox' } });
    expect(s.query('p')).toHaveText('Sin datos');
    expect(s.query('mat-icon')).toHaveText('inbox');
  });

  it('usa inbox como icono por defecto', () => {
    const s = create({ props: { mensaje: 'Vacío' } });
    expect(s.query('mat-icon')).toHaveText('inbox');
  });
});
