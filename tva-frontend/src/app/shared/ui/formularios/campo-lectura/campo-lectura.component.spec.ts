import { createComponentFactory } from '@ngneat/spectator/jest';

import { CampoLecturaComponent } from './campo-lectura.component';

describe('CampoLecturaComponent', () => {
  const create = createComponentFactory({ component: CampoLecturaComponent });

  it('muestra etiqueta y valor, y — cuando el valor es nulo', () => {
    const s = create({ props: { etiqueta: 'Producto', valor: 'PIAS' } });
    expect(s.query('.etiqueta')).toHaveText('Producto');
    expect(s.query('.valor')).toHaveText('PIAS');
    s.setInput('valor', null);
    expect(s.query('.valor')).toHaveText('—');
  });
});
