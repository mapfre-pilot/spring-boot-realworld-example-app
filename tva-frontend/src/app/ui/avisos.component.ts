/** Equivale a rule!MU_Aviso / TVA_MostrarAvisos: avisos por tipo (§12.3). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

import { Aviso } from '@tva/core';

@Component({
  selector: 'app-avisos',
  imports: [MatCardModule, MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @for (aviso of visibles(); track $index) {
      <mat-card class="aviso" [class]="'aviso aviso-' + estilo(aviso)">
        <mat-card-content>
          <mat-icon>{{ icono(aviso) }}</mat-icon>
          <span class="aviso-texto">{{ texto(aviso) }}</span>
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
    .aviso-warning {
      border-left: 4px solid #f9a800;
    }
    .aviso-info {
      border-left: 4px solid #0067b1;
    }
  `,
})
export class AvisosComponent {
  readonly avisos = input.required<Aviso[]>();
  readonly mostrarEn = input<'CABECERA' | 'SECCION'>('CABECERA');

  visibles(): Aviso[] {
    return this.avisos().filter(a => (a.mostrarEn ?? 'CABECERA') === this.mostrarEn());
  }

  texto(aviso: Aviso): string {
    return aviso.texto ?? aviso.mensaje ?? '';
  }

  estilo(aviso: Aviso): 'error' | 'warning' | 'info' {
    const t = aviso.tipo ?? (aviso.codigo?.includes('ERROR') ? 'ERROR' : 'INFO');
    if (t === 'ERROR') return 'error';
    if (t === 'WARNING') return 'warning';
    return 'info';
  }

  icono(aviso: Aviso): string {
    const e = this.estilo(aviso);
    return e === 'error' ? 'error' : e === 'warning' ? 'warning' : 'info';
  }
}
