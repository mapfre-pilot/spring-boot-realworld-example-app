import { createComponentFactory } from '@ngneat/spectator/jest';

import { EncabezadoPantallaComponent } from './encabezado-pantalla.component';

describe('EncabezadoPantallaComponent', () => {
  const create = createComponentFactory({ component: EncabezadoPantallaComponent });

  it('renderiza título y subtítulo', () => {
    const s = create({ props: { titulo: 'Datos de la solicitud', subtitulo: '00427 - PIAS' } });
    expect(s.query('.titulo')).toHaveText('Datos de la solicitud');
    expect(s.query('.subtitulo')).toHaveText('00427 - PIAS');
  });

  it('omite el subtítulo cuando no se informa', () => {
    const s = create({ props: { titulo: 'T' } });
    expect(s.query('.subtitulo')).toBeNull();
  });
});
