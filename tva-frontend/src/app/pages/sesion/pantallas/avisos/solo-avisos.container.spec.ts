import { createComponentFactory } from '@ngneat/spectator/jest';

import { SoloAvisosContainer } from './solo-avisos.container';

describe('SoloAvisosContainer', () => {
  const create = createComponentFactory({ component: SoloAvisosContainer });

  it('muestra la pantalla de avisos', () => {
    const s = create();
    expect(s.query('.titulo')).toHaveText('Avisos');
    expect(s.query('mat-card-content')).toHaveText('Consulte los avisos');
  });
});
