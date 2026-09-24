/** Equivale a rule!MU_Aviso / TVA_MostrarAvisos: lista de avisos por clase. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

import { Aviso } from '../../core/models/models';

@Component({
  selector: 'app-avisos',
  imports: [MatCardModule, MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @for (aviso of avisos(); track $index) {
      <mat-card class="aviso" [class]="'aviso aviso-' + estilo(aviso)">
        <mat-card-content>
          <mat-icon>{{ icono(aviso) }}</mat-icon>
          <span class="aviso-texto">{{ aviso.mensaje }}</span>
        </mat-card-content>
      </mat-card>
    }
  `,
  styles: `
    .aviso {
      margin-bottom: 8px;
    }
    .aviso mat-card-content {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .aviso-error {
      border-left: 4px solid #d81e05;
    }
    .aviso-aviso {
      border-left: 4px solid #f9a800;
    }
    .aviso-info {
      border-left: 4px solid #0067b1;
    }
  `,
})
export class AvisosComponent {
  readonly avisos = input.required<Aviso[]>();

  /** clase 3=BUSQUEDA_RIC,5=DISCREPANCIAS… — convención: ERROR si el código acaba en _ERROR. */
  estilo(aviso: Aviso): 'error' | 'aviso' | 'info' {
    if (aviso.codigo.includes('ERROR')) return 'error';
    return 'info';
  }

  icono(aviso: Aviso): string {
    return this.estilo(aviso) === 'error' ? 'error' : 'info';
  }
}
