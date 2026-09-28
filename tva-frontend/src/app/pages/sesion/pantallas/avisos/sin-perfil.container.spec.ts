import { createComponentFactory } from '@ngneat/spectator/jest';

import { SinPerfilContainer } from './sin-perfil.container';

describe('SinPerfilContainer', () => {
  const create = createComponentFactory({ component: SinPerfilContainer });

  it('muestra el aviso de usuario sin perfil', () => {
    const s = create();
    expect(s.query('mat-card-title')).toHaveText('Sin perfil');
    expect(s.query('mat-card-content')).toHaveText('no dispone de perfil');
  });
});
