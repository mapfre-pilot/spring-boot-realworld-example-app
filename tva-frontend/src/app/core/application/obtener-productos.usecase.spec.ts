import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY } from '../ports';
import { ObtenerProductosUsecase } from './obtener-productos.usecase';

describe('ObtenerProductosUsecase', () => {
  let spectator: SpectatorService<ObtenerProductosUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ObtenerProductosUsecase,
    providers: [{ provide: CATALOGO_REPOSITORY, useValue: { productos: metodo } }],
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
