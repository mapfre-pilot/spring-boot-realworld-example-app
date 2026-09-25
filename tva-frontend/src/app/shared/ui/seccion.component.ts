/** Sección dentro de una caja — plegado con validez y botón Continuar (§12.2). */
import { ChangeDetectionStrategy, Component, computed, input, output } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatIconModule } from '@angular/material/icon';

import { Aviso } from '../../core/models/models';
import { AvisosComponent } from './avisos.component';

@Component({
  selector: 'app-seccion',
  imports: [MatExpansionModule, MatButtonModule, MatIconModule, AvisosComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-expansion-panel [expanded]="expandida()">
      <mat-expansion-panel-header>
        <mat-panel-title>
          {{ titulo() }}
          @if (valida()) {
            <mat-icon class="icono-ok">check_circle</mat-icon>
          } @else if (tocada()) {
            <mat-icon class="icono-error">error</mat-icon>
          }
        </mat-panel-title>
      </mat-expansion-panel-header>
      <app-avisos [avisos]="avisosSeccion()" />
      <ng-content />
      <div class="acciones">
        <button mat-flat-button color="primary" (click)="continuar.emit()">Continuar</button>
      </div>
    </mat-expansion-panel>
  `,
  styles: `
    .icono-ok {
      color: #2e7d32;
      font-size: 18px;
      margin-left: 8px;
    }
    .icono-error {
      color: #c62828;
      font-size: 18px;
      margin-left: 8px;
    }
    .acciones {
      display: flex;
      justify-content: flex-end;
      margin-top: 8px;
    }
  `,
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
