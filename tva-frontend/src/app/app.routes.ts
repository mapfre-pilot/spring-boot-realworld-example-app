import { Routes } from '@angular/router';

import { authGuard, roleGuard } from './core/auth/guards';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./pages/login/login.page').then(m => m.LoginPage) },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () => import('./pages/inicio/inicio.page').then(m => m.InicioPage),
  },
  {
    path: 'sesion/:clave',
    canActivate: [authGuard],
    loadComponent: () => import('./pages/sesion/sesion.page').then(m => m.SesionPage),
  },
  {
    path: 'admin',
    canActivate: [roleGuard('TVA_ADMIN_PORTAL')],
    loadComponent: () => import('./pages/admin/admin.page').then(m => m.AdminPage),
  },
  { path: '**', redirectTo: '' },
];
