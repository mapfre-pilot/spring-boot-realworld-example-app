import { createServiceFactory, SpectatorService } from '@ngneat/spectator/jest';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { of, throwError } from 'rxjs';

import { TvaApiService } from '../api/tva-api.service';
import { AppianPopupService } from './appian-popup.service';

describe('AppianPopupService', () => {
  const api = { lanzarPopup: jest.fn(), completarPopup: jest.fn() };
  const dialog = { open: jest.fn() };
  const snack = { open: jest.fn() };
  const create = createServiceFactory({
    service: AppianPopupService,
    providers: [
      { provide: TvaApiService, useValue: api },
      { provide: MatDialog, useValue: dialog },
      { provide: MatSnackBar, useValue: snack },
    ],
  });

  beforeEach(() => jest.clearAllMocks());

  it('lanzar → diálogo → completar con el resultado del diálogo', done => {
    const s = create();
    api.lanzarPopup.mockReturnValue(
      of({ popup: 'rgpd', idxTomador: 0, taskId: 't-1', taskUrl: '', modo: 'mock' })
    );
    dialog.open.mockReturnValue({ afterClosed: () => of('SUBMIT') });
    api.completarPopup.mockReturnValue(
      of({ pantallaActual: 'X', avisos: [], estado: {}, botones: [] })
    );
    s.service.abrir('k', 'rgpd', 0, 'Consentimiento RGPD').subscribe(res => {
      expect(api.lanzarPopup).toHaveBeenCalledWith('k', 'rgpd', 0);
      expect(dialog.open).toHaveBeenCalled();
      expect(api.completarPopup).toHaveBeenCalledWith('k', 'rgpd', {
        idxTomador: 0,
        taskId: 't-1',
        resultado: 'SUBMIT',
      });
      done();
    });
  });

  it('error en lanzar → snackbar y propaga el error', done => {
    const s = create();
    api.lanzarPopup.mockReturnValue(
      throwError(() => ({ error: { error: { mensaje: 'Appian no disponible' } } }))
    );
    s.service.abrir('k', 'dni', 0, 'Digitalizar NIF / NIE').subscribe({
      error: () => {
        expect(snack.open).toHaveBeenCalled();
        expect(api.completarPopup).not.toHaveBeenCalled();
        done();
      },
    });
  });
});
