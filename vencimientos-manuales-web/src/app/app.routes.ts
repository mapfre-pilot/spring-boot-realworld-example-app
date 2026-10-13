import { Route } from '@angular/router';
import { ExpedientesSearchPageComponent } from './ui/pages/expedientes-search-page.component';
import { ExpedienteManagementPageComponent } from './ui/pages/expediente-management-page.component';
import { VariablesPageComponent } from './ui/pages/variables-page.component';
import { FiniquitosPageComponent } from './ui/pages/finiquitos-page.component';
import { InformesPageComponent } from './ui/pages/informes-page.component';
import { BdgiPageComponent } from './ui/pages/bdgi-page.component';
import { ReaseguroPageComponent } from './ui/pages/reaseguro-page.component';
import { CarteraPolizaPageComponent } from './ui/pages/cartera-poliza-page.component';
import { CarterasPageComponent } from './ui/pages/carteras-page.component';
import { CargaFicheroPageComponent } from './ui/pages/carga-fichero-page.component';

export const appRoutes: Route[] = [
  { path: '', pathMatch: 'full', redirectTo: 'expedientes' },
  { path: 'expedientes', component: ExpedientesSearchPageComponent },
  { path: 'expedientes/nuevo', component: ExpedienteManagementPageComponent },
  {
    path: 'expedientes/:anio/:numero',
    component: ExpedienteManagementPageComponent,
  },
  { path: 'variables', component: VariablesPageComponent },
  { path: 'finiquitos', component: FiniquitosPageComponent },
  { path: 'informes', component: InformesPageComponent },
  { path: 'bdgi', component: BdgiPageComponent },
  { path: 'reaseguro', component: ReaseguroPageComponent },
  { path: 'cartera-poliza', component: CarteraPolizaPageComponent },
  { path: 'carteras', component: CarterasPageComponent },
  { path: 'carga-fichero', component: CargaFicheroPageComponent },
  { path: '**', redirectTo: 'expedientes' },
];
