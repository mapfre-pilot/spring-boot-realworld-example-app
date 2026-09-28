import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { AlternarAperturaCierreUsecase } from './alternar-apertura-cierre.usecase';

describe('AlternarAperturaCierreUsecase', () => {
  let spectator: SpectatorService<AlternarAperturaCierreUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: AlternarAperturaCierreUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { aperturaCierre: metodo } }],
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
