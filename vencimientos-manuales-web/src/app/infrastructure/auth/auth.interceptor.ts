import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { OAuthService } from 'angular-oauth2-oidc';
import { environment } from '../../../environments/environment';

export const authInterceptor: HttpInterceptorFn = (request, next) => {
  if (!environment.auth.enabled) return next(request);
  const token = inject(OAuthService).getAccessToken();
  return next(
    token
      ? request.clone({ setHeaders: { Authorization: `Bearer ${token}` } })
      : request
  );
};
