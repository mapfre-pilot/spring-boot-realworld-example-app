import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { ADMIN_REPOSITORY } from '../ports';
import { ProbarConfiguracionUsecase } from './probar-configuracion.usecase';

describe('ProbarConfiguracionUsecase', () => {
  let spectator: SpectatorService<ProbarConfiguracionUsecase>;
  const metodo = jest.fn().mockReturnValue(of([]));
  const createService = createServiceFactory({
    service: ProbarConfiguracionUsecase,
    providers: [{ provide: ADMIN_REPOSITORY, useValue: { probarConfiguracion: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('execute llama al puerto', () => {
    spectator.service.execute('apilife').subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
