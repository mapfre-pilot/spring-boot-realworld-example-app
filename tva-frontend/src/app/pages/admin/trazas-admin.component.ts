/** Búsqueda y tabla de trazas (vista presentacional de Administración). */
import { ChangeDetectionStrategy, Component, inject, input, output } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';

import { Traza } from '@tva/core';
import { EstadoVacioComponent } from '../../shared/ui/feedback/estado-vacio.component';

@Component({
  selector: 'app-trazas-admin',
  imports: [
    ReactiveFormsModule,
    MatTableModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    EstadoVacioComponent,
  ],
  templateUrl: './trazas-admin.component.html',
  styleUrl: './trazas-admin.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class TrazasAdminComponent {
  readonly trazas = input.required<Traza[]>();
  readonly buscar = output<string>();
  readonly trazaForm = inject(FormBuilder).nonNullable.group({ clave: [''] });
  protected readonly columnasTrazas = ['creado', 'clase', 'mensaje'];

  protected buscarTrazas(): void {
    this.buscar.emit(this.trazaForm.value.clave ?? '');
  }
}
