import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { GarantiasComponent } from './garantias.component';

describe('GarantiasComponent', () => {
  const create = createComponentFactory(GarantiasComponent);

  it('emite garantiaCambiada con índice y selección', () => {
    const s: Spectator<GarantiasComponent> = create({
      props: { garantias: [{ codigo: 'G1', descripcion: 'g', obligatoria: false }] },
    });
    const spy = jest.fn();
    s.component.garantiaCambiada.subscribe(spy);
    s.component.garantiaCambiada.emit({ i: 0, sel: true });
    expect(spy).toHaveBeenCalledWith({ i: 0, sel: true });
    expect(s.query('mat-checkbox')).toBeTruthy();
  });
});
