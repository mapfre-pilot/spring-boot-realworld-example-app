import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY } from '../ports';
import { BuscarClienteUsecase } from './buscar-cliente.usecase';

describe('BuscarClienteUsecase', () => {
  let spectator: SpectatorService<BuscarClienteUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: BuscarClienteUsecase,
    providers: [{ provide: CATALOGO_REPOSITORY, useValue: { clientes: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute('X1').subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
