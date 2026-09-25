/** Sección Opciones de inversión (tabla con importes) — presentacional (§12.4.4). */
import { ChangeDetectionStrategy, Component, input, output } from '@angular/core';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

import { Aviso } from '@tva/core';
import { SeccionComponent } from '../../../../ui/seccion.component';

export interface OpcionInversion {
  investmentPreferenceCode: string;
  descripcion: string;
  seleccionada?: boolean;
}

export interface ImporteOpcion {
  unica?: number;
  periodica?: number;
  plazo?: number;
}

@Component({
  selector: 'app-opciones-inversion',
  imports: [SeccionComponent, MatCheckboxModule, MatFormFieldModule, MatInputModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './opciones-inversion.component.html',
  styleUrl: './opciones-inversion.component.scss',
})
export class OpcionesInversionComponent {
  readonly opciones = input.required<OpcionInversion[]>();
  readonly seleccionadas = input<boolean[]>([]);
  readonly importes = input<Record<string, ImporteOpcion>>({});
  readonly sumaUnica = input(0);
  readonly sumaPeriodica = input(0);
  readonly valida = input(false);
  readonly expandida = input(false);
  readonly avisos = input<Aviso[]>([]);
  readonly continuar = output<void>();
  readonly opcionCambiada = output<{ i: number; sel: boolean }>();
  readonly importeCambiado = output<{
    i: number;
    campo: 'unica' | 'periodica' | 'plazo';
    ev: Event;
  }>();

  importe(i: number, campo: 'unica' | 'periodica' | 'plazo'): number | string {
    return this.importes()[i]?.[campo] ?? '';
  }
}
