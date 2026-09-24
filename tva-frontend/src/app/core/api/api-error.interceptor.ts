import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { catchError, throwError } from 'rxjs';

import { ApiError } from '../models/models';

export const errorInterceptor: HttpInterceptorFn = (req, next) => {
  const snack = inject(MatSnackBar);
  return next(req).pipe(
    catchError((err: HttpErrorResponse) => {
      const body = err.error as ApiError | undefined;
      const mensaje = body?.error?.mensaje ?? `Error ${err.status}`;
      if (err.status >= 400) {
        snack.open(mensaje, 'Cerrar', { duration: 6000, panelClass: 'snack-error' });
      }
      return throwError(() => err);
    })
  );
};
