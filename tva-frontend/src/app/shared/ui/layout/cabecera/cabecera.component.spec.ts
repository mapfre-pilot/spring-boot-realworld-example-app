import { createComponentFactory } from '@ngneat/spectator/jest';

import { AuthService } from '@tva/core';
import { CabeceraComponent } from './cabecera.component';

describe('CabeceraComponent', () => {
  const create = createComponentFactory({
    component: CabeceraComponent,
    providers: [{ provide: AuthService, useValue: { usuario: () => 'op1', logout: jest.fn() } }],
  });

  it('muestra la marca, el título y la modalidad', () => {
    const s = create({ props: { modalidad: 'VIA' } });
    expect(s.query('.marca')).toHaveText('MAPFRE');
    expect(s.query('.titulo')).toHaveText('Tarificador Vida Ahorro');
    expect(s.query('.chip-modalidad')).toHaveText('VIA');
    s.click('button');
    expect(s.inject(AuthService).logout).toHaveBeenCalled();
  });
});
