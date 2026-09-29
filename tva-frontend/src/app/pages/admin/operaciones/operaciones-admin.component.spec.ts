import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { OperacionesAdminComponent } from './operaciones-admin.component';

describe('OperacionesAdminComponent', () => {
  const create = createComponentFactory(OperacionesAdminComponent);

  it('emite apertura, cierre y limpieza desde los botones', () => {
    const s: Spectator<OperacionesAdminComponent> = create({
      props: { estadoApertura: 'abierta' },
    });
    const spies = { ap: jest.fn(), ci: jest.fn(), li: jest.fn() };
    s.component.apertura.subscribe(spies.ap);
    s.component.fijarCierre.subscribe(spies.ci);
    s.component.limpiarCaches.subscribe(spies.li);
    const botones = s.queryAll('button');
    botones[0].click();
    expect(spies.ap).toHaveBeenCalled();
    botones[2].click();
    expect(spies.ci).toHaveBeenCalledWith('1');
    botones[3].click();
    expect(spies.li).toHaveBeenCalled();
  });

  it('muestra el estado en un chip', () => {
    const s: Spectator<OperacionesAdminComponent> = create({
      props: { estadoApertura: 'cerrada' },
    });
    expect(s.query('.chip-estado.error')).toBeTruthy();
  });
});
