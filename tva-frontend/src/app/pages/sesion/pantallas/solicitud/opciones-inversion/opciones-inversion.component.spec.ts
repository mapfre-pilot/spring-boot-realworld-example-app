import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { OpcionesInversionComponent } from './opciones-inversion.component';

describe('OpcionesInversionComponent', () => {
  const create = createComponentFactory(OpcionesInversionComponent);

  it('importe devuelve el valor guardado o cadena vacía', () => {
    const s: Spectator<OpcionesInversionComponent> = create({
      props: {
        opciones: [{ investmentPreferenceCode: 'F1', descripcion: 'Fondo 1' }],
        importes: { 0: { unica: 100, periodica: 50 } },
      },
    });
    expect(s.component['importe'](0, 'unica')).toBe(100);
    expect(s.component['importe'](0, 'periodica')).toBe(50);
    expect(s.component['importe'](0, 'plazo')).toBe('');
    expect(s.component['importe'](1, 'unica')).toBe('');
  });

  it('renderiza la tabla dentro de .tabla-scroll', () => {
    const s: Spectator<OpcionesInversionComponent> = create({
      props: { opciones: [{ investmentPreferenceCode: 'F1', descripcion: 'F' }] },
    });
    expect(s.query('.tabla-scroll table')).toBeTruthy();
  });
});
