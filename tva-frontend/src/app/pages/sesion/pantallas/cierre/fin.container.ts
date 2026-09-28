/** FIN: cierre de la sesión y vuelta a inicio. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { Router } from '@angular/router';

import { SesionStore } from '@tva/core';
import { PanelResultadoComponent } from '../../../../shared/ui/feedback/panel-resultado.component';

@Component({
  selector: 'app-fin',
  imports: [MatButtonModule, PanelResultadoComponent],
  templateUrl: './fin.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FinContainer {
  private readonly store = inject(SesionStore);
  private readonly router = inject(Router);

  protected volver(): void {
    this.store.limpiar();
    void this.router.navigate(['/']);
  }
}
