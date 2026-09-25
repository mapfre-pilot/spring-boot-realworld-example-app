import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { AvisosComponent } from './avisos.component';

describe('AvisosComponent', () => {
  const create = createComponentFactory(AvisosComponent);
  let spectator: Spectator<AvisosComponent>;

  it('renderiza avisos por clase', () => {
    spectator = create({
      props: {
        avisos: [
          { clase: 1, tipo: 'ERROR', texto: 'fallo', mostrarEn: 'CABECERA' },
          { clase: 2, tipo: 'INFO', texto: 'todo bien', mostrarEn: 'CABECERA' },
          { clase: 3, tipo: 'INFO', texto: 'sección', mostrarEn: 'SECCION' },
        ],
      },
    });
    expect(spectator.queryAll('.aviso')).toHaveLength(2);
    expect(spectator.query('.aviso-error')).toExist();
    expect(spectator.element.textContent).toContain('fallo');
  });
});
