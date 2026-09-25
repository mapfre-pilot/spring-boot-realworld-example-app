import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { POPUP_APPIAN_REPOSITORY } from '../ports';
import { SesionStore } from './state/sesion.store';
import { CompletarPopupAppianUsecase } from './completar-popup-appian.usecase';

describe('CompletarPopupAppianUsecase', () => {
  let spectator: SpectatorService<CompletarPopupAppianUsecase>;
  const metodo = jest.fn().mockReturnValue(of({ estado: {} }));
  const createService = createServiceFactory({
    service: CompletarPopupAppianUsecase,
    providers: [{ provide: POPUP_APPIAN_REPOSITORY, useValue: { completar: metodo } }],
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
    spectator.service
      .execute('rgpd', { idxTomador: 0, taskId: 't', resultado: 'SUBMIT' })
      .subscribe();
    expect(metodo).toHaveBeenCalled();
  });
});
