import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';
import { EjecutarAccionUsecase } from './ejecutar-accion.usecase';

describe('EjecutarAccionUsecase', () => {
  let spectator: SpectatorService<EjecutarAccionUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: EjecutarAccionUsecase,
    providers: [{ provide: SESION_REPOSITORY, useValue: { ejecutarAccion: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.inject(SesionStore).sesion.set({ clave: 'K', estado: {}, botones: [] } as never);
    spectator.service.execute('siguiente', {}).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
