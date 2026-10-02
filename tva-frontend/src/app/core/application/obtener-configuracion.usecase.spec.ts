import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { ObtenerConfiguracionUsecase } from './obtener-configuracion.usecase';

describe('ObtenerConfiguracionUsecase', () => {
  let spectator: SpectatorService<ObtenerConfiguracionUsecase>;
  const metodo = jest.fn().mockReturnValue(of([]));
  const createService = createServiceFactory({
    service: ObtenerConfiguracionUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { configuracion: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute().subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
