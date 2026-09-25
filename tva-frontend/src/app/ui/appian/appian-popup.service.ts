/** Orquesta el flujo de un pop-up Appian: lanzar (taskId) → diálogo → completar. */
import { inject, Injectable } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, Observable, switchMap, throwError } from 'rxjs';

import {
  AccionResponse,
  CompletarPopupAppianUsecase,
  LanzarPopupAppianUsecase,
  PopupAppian,
  PopupResultado,
} from '@tva/core';

import { AppianTaskDialogComponent, AppianTaskDialogData } from '../appian-task-dialog.component';

@Injectable({ providedIn: 'root' })
export class AppianPopupService {
  private readonly lanzar = inject(LanzarPopupAppianUsecase);
  private readonly completar = inject(CompletarPopupAppianUsecase);
  private readonly dialog = inject(MatDialog);
  private readonly snack = inject(MatSnackBar);

  abrir(popup: PopupAppian, idxTomador: number, titulo: string): Observable<AccionResponse> {
    return this.lanzar.execute(popup, idxTomador).pipe(
      catchError(err => {
        const mensaje =
          (err?.error?.error?.mensaje as string | undefined) ?? 'Appian no disponible';
        this.snack.open(mensaje, 'Cerrar', { duration: 5000 });
        return throwError(() => err);
      }),
      switchMap(lanzado => {
        const ref = this.dialog.open(AppianTaskDialogComponent, {
          disableClose: true,
          width: '900px',
          data: { titulo, taskId: lanzado.taskId, modo: lanzado.modo } as AppianTaskDialogData,
        });
        return ref.afterClosed().pipe(
          switchMap(resultado =>
            this.completar.execute(popup, {
              idxTomador,
              taskId: lanzado.taskId,
              resultado: (resultado as PopupResultado | undefined) ?? 'DISMISS',
            })
          )
        );
      })
    );
  }
}
