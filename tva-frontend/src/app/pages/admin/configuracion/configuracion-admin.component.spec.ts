import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY, CampoConfiguracion } from '@tva/core';
import { ConfiguracionAdminComponent } from './configuracion-admin.component';

const CAMPOS: CampoConfiguracion[] = [
  {
    nombre: 'RIC_MODE',
    grupo: 'ric',
    grupoEtiqueta: 'RIC',
    etiqueta: 'Modo',
    tipo: 'modo',
    valor: 'mock',
    configurado: true,
    origen: 'entorno',
  },
  {
    nombre: 'RIC_PASSWORD',
    grupo: 'ric',
    grupoEtiqueta: 'RIC',
    etiqueta: 'Contraseña',
    tipo: 'secreto',
    valor: null,
    configurado: true,
    origen: 'bd',
  },
];

describe('ConfiguracionAdminComponent', () => {
  const repo = {
    configuracion: jest.fn().mockReturnValue(of(CAMPOS)),
    guardarConfiguracion: jest.fn().mockReturnValue(of(CAMPOS)),
    probarConfiguracion: jest.fn().mockReturnValue(of({ ok: true, salida: 'OK  ric' })),
  };
  const create = createComponentFactory({
    component: ConfiguracionAdminComponent,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: repo }],
    shallow: true,
  });

  beforeEach(() => jest.clearAllMocks());

  it('agrupa los campos y no rellena los secretos', () => {
    const s: Spectator<ConfiguracionAdminComponent> = create();
    expect(s.component['grupos']()).toHaveLength(1);
    expect(s.component['valor'](CAMPOS[1])).toBe('');
    expect(s.component['modo'](s.component['grupos']()[0])).toBe('mock');
  });

  it('guardar envía solo los cambios del grupo y los limpia', () => {
    const s: Spectator<ConfiguracionAdminComponent> = create();
    s.component['cambiar']('RIC_MODE', 'real');
    s.component['guardar'](s.component['grupos']()[0]);
    expect(repo.guardarConfiguracion).toHaveBeenCalledWith({
      valores: { RIC_MODE: 'real' },
      restablecer: [],
    });
    expect(s.component['cambios']()).toEqual({});
  });

  it('restablecer borra solo los valores guardados en BD', () => {
    const s: Spectator<ConfiguracionAdminComponent> = create();
    s.component['restablecer'](s.component['grupos']()[0]);
    expect(repo.guardarConfiguracion).toHaveBeenCalledWith({
      valores: {},
      restablecer: ['RIC_PASSWORD'],
    });
  });

  it('probar delega con el NIF y guarda el resultado', () => {
    const s: Spectator<ConfiguracionAdminComponent> = create();
    s.component['cambiarNif']('ric', '12345678Z');
    s.component['probar']('ric');
    expect(repo.probarConfiguracion).toHaveBeenCalledWith('ric', '12345678Z');
    expect(s.component['resultados']()['ric'].ok).toBe(true);
  });
});
