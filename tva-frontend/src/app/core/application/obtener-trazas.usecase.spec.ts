import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { ObtenerTrazasUsecase } from './obtener-trazas.usecase';

describe('ObtenerTrazasUsecase', () => {
  let spectator: SpectatorService<ObtenerTrazasUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ObtenerTrazasUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { trazas: metodo } }],
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
