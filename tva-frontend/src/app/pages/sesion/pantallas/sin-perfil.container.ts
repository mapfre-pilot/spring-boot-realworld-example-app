/** SIN_PERFIL: usuario sin perfil TVA. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

@Component({
  selector: 'app-sin-perfil',
  imports: [MatCardModule],
  templateUrl: './sin-perfil.container.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SinPerfilContainer {}
