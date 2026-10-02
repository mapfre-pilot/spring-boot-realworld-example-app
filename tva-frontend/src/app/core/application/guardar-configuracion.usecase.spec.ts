import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { GuardarConfiguracionUsecase } from './guardar-configuracion.usecase';

describe('GuardarConfiguracionUsecase', () => {
  let spectator: SpectatorService<GuardarConfiguracionUsecase>;
  const metodo = jest.fn().mockReturnValue(of([]));
  const createService = createServiceFactory({
    service: GuardarConfiguracionUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { guardarConfiguracion: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute({ valores: {}, restablecer: [] }).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
