/** SOLO_AVISOS: la sesión solo puede mostrar avisos. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-solo-avisos',
  imports: [MatCardModule],
  templateUrl: './solo-avisos.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SoloAvisosContainer {}
