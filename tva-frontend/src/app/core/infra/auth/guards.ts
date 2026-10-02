import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.autenticado()) return true;
  // Sin sesión activa se muestra la bienvenida; el acceso (SSO o token local)
  // lo inicia el usuario desde allí.
  return inject(Router).createUrlTree(['/bienvenida']);
};

/** Guard por rol (p.ej. roleGuard('TVA_ADMIN_PORTAL')). */
export function roleGuard(role: string): CanActivateFn {
  return () => {
    const auth = inject(AuthService);
    if (auth.autenticado() && auth.hasRole(role)) return true;
    return inject(Router).createUrlTree(['/']);
  };
}
