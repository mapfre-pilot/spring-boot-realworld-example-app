import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { MigasDePanComponent } from './migas-de-pan.component';
import { Pantalla } from '@tva/core';

describe('MigasDePanComponent', () => {
  const create = createComponentFactory(MigasDePanComponent);

  it('resalta el paso actual', () => {
    const s: Spectator<MigasDePanComponent> = create({
      props: {
        pasos: [Pantalla.SEGUROS_AHORRO, Pantalla.CAPTURA_DATOS_SOLICITUD],
        actual: Pantalla.CAPTURA_DATOS_SOLICITUD,
      },
    });
    expect(s.query('.paso.activo')?.textContent).toContain('Datos solicitud');
  });
});
