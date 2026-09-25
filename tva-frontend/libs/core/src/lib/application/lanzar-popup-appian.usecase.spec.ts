import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { POPUP_APPIAN_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';
import { LanzarPopupAppianUsecase } from './lanzar-popup-appian.usecase';

describe('LanzarPopupAppianUsecase', () => {
  let spectator: SpectatorService<LanzarPopupAppianUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: LanzarPopupAppianUsecase,
    providers: [{ provide: POPUP_APPIAN_REPOSITORY, useValue: { lanzar: metodo } }],
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
    spectator.service.execute('rgpd', 0).subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
