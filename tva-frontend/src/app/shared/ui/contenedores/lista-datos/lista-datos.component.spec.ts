import { createComponentFactory } from '@ngneat/spectator/jest';

import { ListaDatosComponent } from './lista-datos.component';

describe('ListaDatosComponent', () => {
  const create = createComponentFactory({ component: ListaDatosComponent });

  it('renderiza etiquetas y valores; null muestra —', () => {
    const s = create({
      props: {
        items: [
          { etiqueta: 'Importe', valor: '1.200 €' },
          { etiqueta: 'IBAN', valor: null },
        ],
      },
    });
    const items = s.queryAll('.item');
    expect(items).toHaveLength(2);
    expect(items[0].querySelector('.valor')).toHaveText('1.200 €');
    expect(items[1].querySelector('.valor')).toHaveText('—');
  });

  it('aplica el número de columnas', () => {
    const s = create({ props: { items: [], columnas: 4 } });
    expect(s.query('.lista')?.classList.contains('cols-4')).toBe(true);
  });
});
