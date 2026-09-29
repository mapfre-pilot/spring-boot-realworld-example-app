/** Toolbar de operaciones de administración (batch, apertura/cierre, cachés). */
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';

@Component({
  selector: 'app-operaciones-admin',
  imports: [MatButtonModule, MatIconModule],
  templateUrl: './operaciones-admin.component.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class OperacionesAdminComponent {
  readonly estadoApertura = input.required<string>();
  readonly apertura = output<void>();
  readonly fijarCierre = output<'0' | '1'>();
  readonly limpiarCaches = output<void>();
}
