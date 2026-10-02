import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY } from '../ports';
import { CargarSesionUsecase } from './cargar-sesion.usecase';

describe('CargarSesionUsecase', () => {
  let spectator: SpectatorService<CargarSesionUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: CargarSesionUsecase,
    providers: [{ provide: SESION_REPOSITORY, useValue: { obtener: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute('CLAVE').subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
