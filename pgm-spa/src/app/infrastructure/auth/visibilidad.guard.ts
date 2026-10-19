import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { VisibilidadKey } from '../../domain/models/api.models';

/** Las visibilidades las decide el BFF; la SPA solo las aplica (no es un control de seguridad). */
export const visibilidadGuard =
  (clave: VisibilidadKey): CanActivateFn =>
  async () => {
    const store = inject(ContextoStore);
    const router = inject(Router);
    if (!store.cargado()) await store.cargar();
    return store.puede(clave)
      ? true
      : router.createUrlTree(['/acceso-denegado'], { queryParams: { clave } });
  };
