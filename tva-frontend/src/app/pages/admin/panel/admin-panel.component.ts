/** Panel de administración reutilizable dentro de la sesión (pantalla ADMINISTRACION). */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTabsModule } from '@angular/material/tabs';

import { EncabezadoPantallaComponent } from '../../../shared/ui/layout/encabezado-pantalla/encabezado-pantalla.component';
import { AdminPage } from '../admin/admin.page';
import { OperacionesAdminComponent } from '../operaciones-admin/operaciones-admin.component';
import { ParametrosAdminComponent } from '../parametros-admin/parametros-admin.component';
import { TrazasAdminComponent } from '../trazas-admin/trazas-admin.component';

@Component({
  selector: 'app-admin-panel',
  imports: [
    MatCardModule,
    MatTabsModule,
    EncabezadoPantallaComponent,
    ParametrosAdminComponent,
    OperacionesAdminComponent,
    TrazasAdminComponent,
  ],
  templateUrl: './admin-panel.component.html',
  styleUrl: './admin-panel.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AdminPanelComponent extends AdminPage {}
