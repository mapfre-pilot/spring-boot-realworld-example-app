import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';
import { GuardarEstadoUsecase } from './guardar-estado.usecase';

describe('GuardarEstadoUsecase', () => {
  let spectator: SpectatorService<GuardarEstadoUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: GuardarEstadoUsecase,
    providers: [{ provide: SESION_REPOSITORY, useValue: { guardarEstado: metodo } }],
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
    spectator.service.execute({}).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
