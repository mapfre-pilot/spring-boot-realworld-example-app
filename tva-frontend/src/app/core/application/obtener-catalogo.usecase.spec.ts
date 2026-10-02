import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY } from '../ports';
import { ObtenerCatalogoUsecase } from './obtener-catalogo.usecase';

describe('ObtenerCatalogoUsecase', () => {
  let spectator: SpectatorService<ObtenerCatalogoUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ObtenerCatalogoUsecase,
    providers: [{ provide: CATALOGO_REPOSITORY, useValue: { catalogo: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute('cat').subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
