/** FIN: cierre de la sesión y vuelta a inicio. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { Router } from '@angular/router';

import { SesionStore } from '@tva/core';

@Component({
  selector: 'app-fin',
  imports: [MatCardModule, MatButtonModule],
  templateUrl: './fin.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FinContainer {
  private readonly store = inject(SesionStore);
  private readonly router = inject(Router);

  volver(): void {
    this.store.limpiar();
    void this.router.navigate(['/']);
  }
}
