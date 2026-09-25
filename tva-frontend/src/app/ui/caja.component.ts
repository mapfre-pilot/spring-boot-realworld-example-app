/** Wrapper de caja — equivale a las cajas TVA_Caja_* (tarjeta con título). */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatExpansionModule } from '@angular/material/expansion';

@Component({
  selector: 'app-caja',
  imports: [MatExpansionModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-expansion-panel class="caja" [expanded]="expandida()">
      <mat-expansion-panel-header>
        <mat-panel-title class="titulo-caja">{{ titulo() }}</mat-panel-title>
      </mat-expansion-panel-header>
      <ng-content />
    </mat-expansion-panel>
  `,
  styles: `
    .caja {
      margin-bottom: 16px;
      border-radius: 8px;
      border: 1px solid var(--tva-border, #e0e0e0);
      box-shadow: 0 1px 3px rgb(0 0 0 / 8%);
      background: #fff;
      overflow: hidden;
    }
    .caja .mat-expansion-panel-body {
      padding: 0;
    }
  `,
})
export class CajaComponent {
  readonly titulo = input.required<string>();
  readonly expandida = input(true);
}
