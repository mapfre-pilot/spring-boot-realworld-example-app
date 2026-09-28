import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { BotoneraComponent } from './botonera.component';
import { Boton } from '@tva/core';

const BOTONES: Boton[] = [
  {
    id: 'cancelar',
    label: 'Cancelar',
    visible: true,
    disabled: false,
    confirm: { header: 'h', message: 'm', ok: 'Sí', cancel: 'No' },
  },
  { id: 'contratar', label: 'Contratar', visible: true, disabled: true },
  { id: 'firmar', label: 'Firmar', visible: false, disabled: false },
];

describe('BotoneraComponent', () => {
  const create = createComponentFactory(BotoneraComponent);

  it('solo renderiza los visibles y respeta disabled', () => {
    const s: Spectator<BotoneraComponent> = create({ props: { botones: BOTONES } });
    const botones = s.queryAll('button');
    expect(botones).toHaveLength(2);
    expect(botones[1].disabled).toBe(true);
  });

  it('emite la acción sin confirmación', () => {
    const s: Spectator<BotoneraComponent> = create({ props: { botones: BOTONES } });
    const spy = jest.fn();
    s.component.accion.subscribe(spy);
    s.component.emitir(BOTONES[1]);
    expect(spy).toHaveBeenCalledWith('contratar');
  });
});
