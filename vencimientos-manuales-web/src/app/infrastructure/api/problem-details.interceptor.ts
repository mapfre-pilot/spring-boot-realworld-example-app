import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { catchError, throwError } from 'rxjs';

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
      const problem: ProblemDetails =
        error.error && typeof error.error === 'object'
          ? {
              type: error.error.type || 'about:blank',
              title:
                error.error.title ||
                error.statusText ||
                'Error de comunicación',
              status: error.error.status || error.status,
              detail: error.error.detail,
              instance: error.error.instance,
            }
          : {
              type: 'about:blank',
              title: error.statusText || 'Error de comunicación',
              status: error.status,
            };
      return throwError(() => new ApiProblemError(problem));
    })
  );
