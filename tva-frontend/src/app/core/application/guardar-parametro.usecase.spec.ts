import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { GuardarParametroUsecase } from './guardar-parametro.usecase';

describe('GuardarParametroUsecase', () => {
  let spectator: SpectatorService<GuardarParametroUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: GuardarParametroUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { guardarParametro: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute({}).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
