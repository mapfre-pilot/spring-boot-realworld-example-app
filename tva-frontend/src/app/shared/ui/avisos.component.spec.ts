import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { AvisosComponent } from './avisos.component';

describe('AvisosComponent', () => {
  const create = createComponentFactory(AvisosComponent);
  let spectator: Spectator<AvisosComponent>;

  it('renderiza avisos por clase', () => {
    spectator = create({
      props: {
        avisos: [
          { clase: 1, codigo: 'X_ERROR', mensaje: 'fallo' },
          { clase: 2, codigo: 'OK', mensaje: 'todo bien' },
        ],
      },
    });
    expect(spectator.queryAll('.aviso')).toHaveLength(2);
    expect(spectator.query('.aviso-error')).toExist();
    expect(spectator.element.textContent).toContain('fallo');
  });
});
