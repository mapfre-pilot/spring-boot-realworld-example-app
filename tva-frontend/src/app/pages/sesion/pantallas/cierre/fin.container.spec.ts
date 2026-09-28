import { Router } from '@angular/router';
import { createComponentFactory, mockProvider } from '@ngneat/spectator/jest';

import { SesionStore } from '@tva/core';
import { FinContainer } from './fin.container';

describe('FinContainer', () => {
  const create = createComponentFactory({
    component: FinContainer,
    providers: [mockProvider(Router, { navigate: jest.fn() })],
  });

  it('muestra el cierre y "Nueva sesión" limpia y vuelve al inicio', () => {
    const s = create();
    expect(s.query('mat-card-title')).toHaveText('Sesión finalizada');
    s.click('button');
    expect(s.inject(Router).navigate).toHaveBeenCalledWith(['/']);
    expect(s.inject(SesionStore).sesion()).toBeNull();
  });
});
