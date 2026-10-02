import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';
import { ObtenerDocumentoUsecase } from './obtener-documento.usecase';

describe('ObtenerDocumentoUsecase', () => {
  let spectator: SpectatorService<ObtenerDocumentoUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: ObtenerDocumentoUsecase,
    providers: [{ provide: SESION_REPOSITORY, useValue: { obtenerDocumento: metodo } }],
  });

  beforeEach(() => {
    metodo.mockClear();
    spectator = createService();
  });

  it('should be created', () => {
    expect(spectator.service).toBeTruthy();
  });

  it('execute llama al puerto', () => {
    spectator.inject(SesionStore).sesion.set({ clave: 'K', estado: {}, botones: [] } as never);
    spectator.service.execute('doc').subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
