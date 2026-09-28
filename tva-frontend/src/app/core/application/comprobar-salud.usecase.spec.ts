import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { INICIO_REPOSITORY } from '../ports';
import { ComprobarSaludUsecase } from './comprobar-salud.usecase';

describe('ComprobarSaludUsecase', () => {
  let spectator: SpectatorService<ComprobarSaludUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ComprobarSaludUsecase,
    providers: [{ provide: INICIO_REPOSITORY, useValue: { salud: metodo } }],
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
