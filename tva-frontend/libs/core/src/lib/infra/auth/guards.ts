import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.autenticado()) return true;
  return inject(Router).createUrlTree(['/login']);
};

/** Guard por rol (p.ej. roleGuard('TVA_ADMIN_PORTAL')). */
export function roleGuard(role: string): CanActivateFn {
  return () => {
    const auth = inject(AuthService);
    if (auth.autenticado() && auth.hasRole(role)) return true;
    return inject(Router).createUrlTree(['/']);
  };
}
