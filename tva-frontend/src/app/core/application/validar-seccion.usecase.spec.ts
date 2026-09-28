import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';
import { ValidarSeccionUsecase } from './validar-seccion.usecase';

describe('ValidarSeccionUsecase', () => {
  let spectator: SpectatorService<ValidarSeccionUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ValidarSeccionUsecase,
    providers: [{ provide: SESION_REPOSITORY, useValue: { validarSeccion: metodo } }],
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
    spectator.service.execute('tomadores', 'datosPersonales', {}).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
