import { Route } from '@angular/router';
import { Visibilidad } from './domain/models/api.models';
import { visibilidadGuard } from './infrastructure/auth/visibilidad.guard';
import { MainLayoutComponent } from './ui/components/main-layout.component';

export const appRoutes: Route[] = [
  {
    path: '',
    component: MainLayoutComponent,
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'inicio' },
      {
        path: 'inicio',
        canActivate: [visibilidadGuard(Visibilidad.INICIO)],
        loadComponent: () =>
          import('./ui/pages/inicio-page.component').then((m) => m.InicioPageComponent),
      },
      {
        path: 'clientes/:id',
        canActivate: [visibilidadGuard(Visibilidad.FICHA_CLIENTE)],
        loadComponent: () =>
          import('./ui/pages/ficha-cliente-page.component').then(
            (m) => m.FichaClientePageComponent,
          ),
      },
      {
        path: 'polizas/:numero',
        canActivate: [visibilidadGuard(Visibilidad.FICHA_CLIENTE)],
        loadComponent: () =>
          import('./ui/pages/poliza-page.component').then((m) => m.PolizaPageComponent),
      },
      {
        path: 'recibos/:numero',
        canActivate: [visibilidadGuard(Visibilidad.RECIBOS)],
        loadComponent: () =>
          import('./ui/pages/recibo-page.component').then((m) => m.ReciboPageComponent),
      },
      {
        path: 'nueva-produccion',
        canActivate: [visibilidadGuard(Visibilidad.NUEVA_PRODUCCION)],
        loadComponent: () =>
          import('./ui/pages/nueva-produccion-page.component').then(
            (m) => m.NuevaProduccionPageComponent,
          ),
      },
      {
        path: 'gestion-cartera',
        canActivate: [visibilidadGuard(Visibilidad.GESTION_CARTERA)],
        loadComponent: () =>
          import('./ui/pages/lanzaderas-ramo-page.component').then(
            (m) => m.GestionCarteraPageComponent,
          ),
      },
      {
        path: 'prestaciones',
        canActivate: [visibilidadGuard(Visibilidad.PRESTACIONES)],
        loadComponent: () =>
          import('./ui/pages/lanzaderas-ramo-page.component').then(
            (m) => m.PrestacionesPageComponent,
          ),
      },
      {
        path: 'recibos',
        canActivate: [visibilidadGuard(Visibilidad.RECIBOS)],
        loadComponent: () =>
          import('./ui/pages/recibos-page.component').then((m) => m.RecibosPageComponent),
      },
      {
        path: 'gestion-comercial',
        canActivate: [visibilidadGuard(Visibilidad.GESTION_COMERCIAL)],
        loadComponent: () =>
          import('./ui/pages/gestion-comercial-page.component').then(
            (m) => m.GestionComercialPageComponent,
          ),
      },
      {
        path: 'utilidades',
        canActivate: [visibilidadGuard(Visibilidad.UTILIDADES)],
        loadComponent: () =>
          import('./ui/pages/utilidades-page.component').then((m) => m.UtilidadesPageComponent),
      },
      {
        path: 'cuadro-mando',
        canActivate: [visibilidadGuard(Visibilidad.CUADRO_MANDO)],
        loadComponent: () =>
          import('./ui/pages/cuadro-mando-page.component').then((m) => m.CuadroMandoPageComponent),
      },
      {
        path: 'acceso-denegado',
        loadComponent: () =>
          import('./ui/pages/acceso-denegado-page.component').then(
            (m) => m.AccesoDenegadoPageComponent,
          ),
      },
      { path: '**', redirectTo: 'inicio' },
    ],
  },
];
