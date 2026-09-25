import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { INICIO_REPOSITORY } from '../ports';
import { IniciarSesionUsecase } from './iniciar-sesion.usecase';

describe('IniciarSesionUsecase', () => {
  let spectator: SpectatorService<IniciarSesionUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: IniciarSesionUsecase,
    providers: [{ provide: INICIO_REPOSITORY, useValue: { iniciarAhorro: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute({ indFunctionMode: 'VA' } as never).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
