/** Orquesta el flujo de un pop-up Appian: lanzar (taskId) → diálogo → completar. */
import { inject, Injectable } from '@angular/core';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, Observable, switchMap, throwError } from 'rxjs';

import { AccionResponse, PopupAppian, PopupResultado } from '../models/models';
import { TvaApiService } from '../api/tva-api.service';
import {
  AppianTaskDialogComponent,
  AppianTaskDialogData,
} from '../../shared/ui/appian-task-dialog.component';

@Injectable({ providedIn: 'root' })
export class AppianPopupService {
  private readonly api = inject(TvaApiService);
  private readonly dialog = inject(MatDialog);
  private readonly snack = inject(MatSnackBar);

  abrir(
    clave: string,
    popup: PopupAppian,
    idxTomador: number,
    titulo: string
  ): Observable<AccionResponse> {
    return this.api.lanzarPopup(clave, popup, idxTomador).pipe(
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
            this.api.completarPopup(clave, popup, {
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
