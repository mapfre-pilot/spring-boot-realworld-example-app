/** Equivale a rule!MU_Aviso / TVA_MostrarAvisos: banners ERROR/WARNING/INFO (§12.3). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatIconModule } from '@angular/material/icon';

import { Aviso } from '@tva/core';

@Component({
  selector: 'app-avisos',
  imports: [MatIconModule],
  templateUrl: './avisos.component.html',
  styleUrl: './avisos.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
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
