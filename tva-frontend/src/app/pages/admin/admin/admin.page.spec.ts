import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY, AuthService, Parametro } from '@tva/core';
import { AdminPage } from './admin.page';

const PARAMS: Parametro[] = [
  {
    clave: 'TVA_APLICACION_CERRADA',
    valor: '0',
    tipo: 'bool',
    descripcion: '',
    entorno: null,
    actualizado: '',
  },
  { clave: 'X', valor: 'v', tipo: 'str', descripcion: '', entorno: null, actualizado: '' },
];

describe('AdminPage', () => {
  const repo = {
    parametros: jest.fn().mockReturnValue(of(PARAMS)),
    guardarParametro: jest.fn().mockReturnValue(of({ ...PARAMS[1], valor: 'w' })),
    aperturaCierre: jest.fn().mockReturnValue(of({ cerrada: true })),
    limpiarCaches: jest.fn().mockReturnValue(of({})),
    trazas: jest.fn().mockReturnValue(of([{ id: 1 }])),
  };
  const create = createComponentFactory({
    component: AdminPage,
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

  it('carga parámetros y deduce el estado de apertura', () => {
    const s: Spectator<AdminPage> = create({ detectChanges: false });
    s.component.ngOnInit();
    expect(s.component['parametros']()).toEqual(PARAMS);
    expect(s.component['estadoApertura']()).toBe('abierta');
  });

  it('guardar sustituye el parámetro actualizado', () => {
    const s: Spectator<AdminPage> = create({ detectChanges: false });
    s.component.ngOnInit();
    s.component['guardar'](PARAMS[1], 'w');
    expect(repo.guardarParametro).toHaveBeenCalledWith({ clave: 'X', valor: 'w' });
    expect(s.component['parametros']()[1].valor).toBe('w');
  });

  it('apertura y fijarCierre actualizan el estado', () => {
    const s: Spectator<AdminPage> = create({ detectChanges: false });
    s.component.ngOnInit();
    s.component['apertura']();
    expect(s.component['estadoApertura']()).toBe('cerrada');
    s.component['fijarCierre']('0');
    expect(s.component['estadoApertura']()).toBe('abierta');
  });

  it('limpiar y buscarTrazas delegan en el repositorio', () => {
    const s: Spectator<AdminPage> = create({ detectChanges: false });
    s.component['limpiar']();
    expect(repo.limpiarCaches).toHaveBeenCalled();
    s.component['buscarTrazas']('clv');
    expect(repo.trazas).toHaveBeenCalledWith('clv');
    expect(s.component['trazas']()).toHaveLength(1);
  });
});
