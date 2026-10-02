/** Panel hero de resultado: icono grande por tipo, título, mensaje y acciones. */
import { ChangeDetectionStrategy, Component, computed, input } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';

export type TipoPanel = 'ok' | 'error' | 'info' | 'aviso';

const ICONOS: Record<TipoPanel, string> = {
  ok: 'check_circle',
  error: 'error',
  info: 'info',
  aviso: 'warning',
};

@Component({
  selector: 'app-panel-resultado',
  imports: [MatCardModule, MatIconModule],
  templateUrl: './panel-resultado.component.html',

  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class PanelResultadoComponent {
  readonly tipo = input.required<TipoPanel>();
  readonly titulo = input.required<string>();
  readonly mensaje = input<string | undefined>(undefined);
  protected readonly icono = computed(() => ICONOS[this.tipo()] ?? 'info');
}
