import { createComponentFactory } from '@ngneat/spectator/jest';

import { SistemaCerradoContainer } from './sistema-cerrado.container';

describe('SistemaCerradoContainer', () => {
  const create = createComponentFactory({ component: SistemaCerradoContainer });

  it('muestra el aviso de aplicación cerrada', () => {
    const s = create();
    expect(s.query('mat-card-title')).toHaveText('Sistema cerrado');
    expect(s.query('mat-card-content')).toHaveText('cerrado fuera del horario');
  });
});
