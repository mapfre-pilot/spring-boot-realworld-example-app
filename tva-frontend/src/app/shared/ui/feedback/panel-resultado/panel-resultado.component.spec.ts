import { createComponentFactory } from '@ngneat/spectator/jest';

import { PanelResultadoComponent } from './panel-resultado.component';

describe('PanelResultadoComponent', () => {
  const create = createComponentFactory({ component: PanelResultadoComponent });

  it.each([
    ['ok', 'check_circle'],
    ['error', 'error'],
    ['info', 'info'],
    ['aviso', 'warning'],
  ] as const)('tipo %s muestra el icono %s', (tipo, icono) => {
    const s = create({ props: { tipo, titulo: 'T' } });
    expect(s.query('.icono')).toHaveText(icono);
    expect(s.query('.panel')?.classList.contains(`panel-${tipo}`)).toBe(true);
  });

  it('renderiza título y mensaje', () => {
    const s = create({ props: { tipo: 'ok', titulo: 'Hecho', mensaje: 'Todo bien' } });
    expect(s.query('.titulo')).toHaveText('Hecho');
    expect(s.query('.mensaje')).toHaveText('Todo bien');
  });

  it('omite el mensaje cuando no se informa', () => {
    const s = create({ props: { tipo: 'info', titulo: 'T' } });
    expect(s.query('.mensaje')).toBeNull();
  });
});
