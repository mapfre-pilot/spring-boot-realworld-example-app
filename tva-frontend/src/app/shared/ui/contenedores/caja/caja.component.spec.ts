import { createComponentFactory } from '@ngneat/spectator/jest';

import { CajaComponent } from './caja.component';

describe('CajaComponent', () => {
  const create = createComponentFactory({ component: CajaComponent });

  it('muestra el título de la caja', () => {
    const s = create({ props: { titulo: 'Datos del seguro' } });
    expect(s.query('.titulo-caja')).toHaveText('Datos del seguro');
    expect(s.query('mat-expansion-panel')).toBeTruthy();
  });
});
