import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';
import { HttpMethod, createHttpFactory } from '@ngneat/spectator/jest';

import { PopupAppianHttpRepository } from './popup-appian-http.repository';

describe('PopupAppianHttpRepository', () => {
  const createService = createHttpFactory({
    service: PopupAppianHttpRepository,
    providers: [
      { provide: ENVIRONMENT, useValue: 'test' },
      { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://test/api' } },
    ],
  });

  it('POST lanzar', () => {
    const spectator = createService();
    spectator.service.lanzar('k', 'rgpd', 0).subscribe();
    const req = spectator.expectOne(
      'http://test/api/sesiones/k/popups/rgpd/lanzar/',
      HttpMethod.POST
    );
    expect(req.request.body).toEqual({ idxTomador: 0 });
    req.flush({ taskId: 't' });
  });

  it('POST completar', () => {
    const spectator = createService();
    spectator.service
      .completar('k', 'dni', { idxTomador: 0, taskId: 't', resultado: 'SUBMIT' })
      .subscribe();
    spectator
      .expectOne('http://test/api/sesiones/k/popups/dni/completar/', HttpMethod.POST)
      .flush({});
  });
});
