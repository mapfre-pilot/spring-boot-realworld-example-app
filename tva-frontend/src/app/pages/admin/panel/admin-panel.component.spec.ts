import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY, AuthService } from '@tva/core';
import { AdminPanelComponent } from './admin-panel.component';

describe('AdminPanelComponent', () => {
  const repo = {
    parametros: jest.fn().mockReturnValue(of([])),
    guardarParametro: jest.fn(),
    aperturaCierre: jest.fn(),
    limpiarCaches: jest.fn(),
    trazas: jest.fn().mockReturnValue(of([])),
  };
  const create = createComponentFactory({
    component: AdminPanelComponent,
    providers: [
      { provide: ADMIN_REPOSITORY, useValue: repo },
      {
        provide: AuthService,
        useValue: {
          usuario: () => 'op',
          hasRole: () => false,
          logout: jest.fn(),
          token: () => null,
        },
      },
    ],
    shallow: true,
  });

  it('hereda el comportamiento de AdminPage y carga parámetros', () => {
    const s: Spectator<AdminPanelComponent> = create({ detectChanges: false });
    s.component.ngOnInit();
    expect(repo.parametros).toHaveBeenCalled();
    expect(s.component['parametros']()).toEqual([]);
  });
});
