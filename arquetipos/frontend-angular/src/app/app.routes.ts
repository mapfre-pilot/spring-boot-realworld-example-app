import { Route } from '@angular/router';

export const appRoutes: Route[] = [
      {
        path: '',
        loadComponent: () => import('./pages/welcome/welcome.page').then(p => p.WelcomePage),
      }
      ];
