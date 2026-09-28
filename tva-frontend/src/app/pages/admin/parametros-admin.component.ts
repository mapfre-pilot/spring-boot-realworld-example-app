/** Tabla de parámetros editables (vista presentacional de Administración). */
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';

import { Parametro } from '@tva/core';
import { EstadoVacioComponent } from '../../shared/ui/feedback/estado-vacio.component';

@Component({
  selector: 'app-parametros-admin',
  imports: [MatTableModule, MatFormFieldModule, MatInputModule, EstadoVacioComponent],
  templateUrl: './parametros-admin.component.html',
  styleUrl: './parametros-admin.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ParametrosAdminComponent {
  readonly parametros = input.required<Parametro[]>();
  readonly guardarValor = output<{ p: Parametro; valor: string }>();
  protected readonly columnas = ['clave', 'valor', 'tipo'];

  protected guardar(p: Parametro, valor: string): void {
    this.guardarValor.emit({ p, valor });
  }
}
