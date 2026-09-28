import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { LimpiarCachesUsecase } from './limpiar-caches.usecase';

describe('LimpiarCachesUsecase', () => {
  let spectator: SpectatorService<LimpiarCachesUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: LimpiarCachesUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { limpiarCaches: metodo } }],
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
