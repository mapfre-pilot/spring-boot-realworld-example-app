import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { ObtenerParametrosUsecase } from './obtener-parametros.usecase';

describe('ObtenerParametrosUsecase', () => {
  let spectator: SpectatorService<ObtenerParametrosUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ObtenerParametrosUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { parametros: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute().subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
