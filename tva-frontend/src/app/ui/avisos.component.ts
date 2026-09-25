/** Equivale a rule!MU_Aviso / TVA_MostrarAvisos: banners ERROR/WARNING/INFO (§12.3). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

import { Aviso } from '@tva/core';

@Component({
  selector: 'app-avisos',
  imports: [MatIconModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @for (aviso of visibles(); track $index) {
      <div class="aviso" [class]="'aviso aviso-' + estilo(aviso)" role="alert">
        <mat-icon aria-hidden="true">{{ icono(aviso) }}</mat-icon>
        <span class="aviso-texto">{{ texto(aviso) }}</span>
      </div>
    }
  `,
  styles: `
    .aviso {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 8px;
      padding: 10px 14px;
      border-radius: 4px;
      font-size: 13px;
      line-height: 1.4;
    }
    .aviso mat-icon {
      flex-shrink: 0;
      font-size: 20px;
      width: 20px;
      height: 20px;
    }
    .aviso-error {
      background: #fdecea;
      border-left: 4px solid var(--tva-primary, #d81e05);
      color: #7f1d12;
    }
    .aviso-warning {
      background: #fff8e1;
      border-left: 4px solid #f9a825;
      color: #7a5d00;
    }
    .aviso-info {
      background: #e8f2fb;
      border-left: 4px solid #1565c0;
      color: #0d3c6e;
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
