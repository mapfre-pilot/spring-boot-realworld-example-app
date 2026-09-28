import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { createServiceFactory } from '@ngneat/spectator/jest';
import { of, throwError } from 'rxjs';

import { CompletarPopupAppianUsecase, LanzarPopupAppianUsecase, SesionStore } from '@tva/core';

import { AppianPopupService } from './appian-popup.service';

const SESION = { clave: 'k', estado: {}, botones: [] };

describe('AppianPopupService', () => {
  const lanzar = { execute: jest.fn() };
  const completar = { execute: jest.fn() };
  const dialog = { open: jest.fn() };
  const snack = { open: jest.fn() };
  const create = createServiceFactory({
    service: AppianPopupService,
    providers: [
      { provide: LanzarPopupAppianUsecase, useValue: lanzar },
      { provide: CompletarPopupAppianUsecase, useValue: completar },
      { provide: MatDialog, useValue: dialog },
      { provide: MatSnackBar, useValue: snack },
    ],
  });

  beforeEach(() => jest.clearAllMocks());

  it('lanzar → diálogo → completar con el resultado del diálogo', done => {
    const s = create();
    s.inject(SesionStore).sesion.set(SESION as never);
    lanzar.execute.mockReturnValue(
      of({ popup: 'rgpd', idxTomador: 0, taskId: 't-1', taskUrl: '', modo: 'mock' })
    );
    dialog.open.mockReturnValue({ afterClosed: () => of('SUBMIT') });
    completar.execute.mockReturnValue(
      of({ pantallaActual: 'X', avisos: [], estado: {}, botones: [] })
    );
    s.service.abrir('rgpd', 0, 'Consentimiento RGPD').subscribe(() => {
      expect(lanzar.execute).toHaveBeenCalledWith('rgpd', 0);
      expect(dialog.open).toHaveBeenCalled();
      expect(completar.execute).toHaveBeenCalledWith('rgpd', {
        idxTomador: 0,
        taskId: 't-1',
        resultado: 'SUBMIT',
      });
      done();
    });
  });

  it('error en lanzar → snackbar y propaga el error', done => {
    const s = create();
    s.inject(SesionStore).sesion.set(SESION as never);
    lanzar.execute.mockReturnValue(
      throwError(() => ({ error: { error: { mensaje: 'Appian no disponible' } } }))
    );
    s.service.abrir('dni', 0, 'Digitalizar NIF / NIE').subscribe({
      error: () => {
        expect(snack.open).toHaveBeenCalled();
        expect(completar.execute).not.toHaveBeenCalled();
        done();
      },
    });
  });
});
