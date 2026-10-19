import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { catchError, throwError } from 'rxjs';

/** Errores del BFF en formato RFC 9457 (BP-API-001). */
export interface ProblemDetails {
  type: string;
  title: string;
  status: number;
  detail?: string;
  instance?: string;
}

export class ApiProblemError extends Error {
  constructor(readonly problem: ProblemDetails) {
    super(problem.detail || problem.title);
    this.name = 'ApiProblemError';
  }
}

export const problemDetailsInterceptor: HttpInterceptorFn = (request, next) =>
  next(request).pipe(
    catchError((error: HttpErrorResponse) => {
      const body = error.error;
      const problem: ProblemDetails =
        error.status !== 0 && body && typeof body === 'object' && ('title' in body || 'detail' in body)
          ? {
              type: body.type || 'about:blank',
              title: body.title || error.statusText || 'Error de comunicación',
              status: body.status || error.status,
              detail: body.detail,
              instance: body.instance,
            }
          : {
              type: 'about:blank',
              title: error.status === 0 ? 'BFF no disponible' : error.statusText || 'Error de comunicación',
              status: error.status,
              detail: error.status === 0 ? 'No se ha podido conectar con el BFF (pgm-bff).' : undefined,
            };
      return throwError(() => new ApiProblemError(problem));
    }),
  );
