/** Sección dentro de una caja — fila plegable con estado de validez (§12.2). */
import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatIconModule } from '@angular/material/icon';

import { Aviso } from '@tva/core';
import { AvisosComponent } from './avisos.component';

@Component({
  selector: 'app-seccion',
  imports: [MatExpansionModule, MatButtonModule, MatIconModule, AvisosComponent],
  templateUrl: './seccion.component.html',
  styleUrl: './seccion.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SeccionComponent {
  readonly titulo = input.required<string>();
  readonly valida = input(false);
  readonly tocada = input(false);
  readonly expandida = input(false);
  readonly avisos = input<Aviso[]>([]);
  readonly seccion = input.required<string>();
  readonly continuar = output<void>();

  readonly avisosSeccion = computed(() =>
    this.avisos().filter(a => a.mostrarEn === 'SECCION' && a.seccion === this.seccion())
  );
}
