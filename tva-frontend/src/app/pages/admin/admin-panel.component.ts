/** Panel de administración reutilizable dentro de la sesión (pantalla ADMINISTRACION). */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';

import { AdminPage } from './admin.page';

@Component({
  selector: 'app-admin-panel',
  imports: [ReactiveFormsModule, MatTableModule, MatButtonModule, MatInputModule],
  templateUrl: './admin-panel.component.html',
  styleUrl: './admin-panel.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AdminPanelComponent extends AdminPage {}
