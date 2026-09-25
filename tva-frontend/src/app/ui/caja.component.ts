/** Wrapper mat-expansion-panel — equivale a las cajas TVA_Caja_*. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { MatExpansionModule } from '@angular/material/expansion';

@Component({
  selector: 'app-caja',
  imports: [MatExpansionModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-expansion-panel [expanded]="expandida()">
      <mat-expansion-panel-header>
        <mat-panel-title>{{ titulo() }}</mat-panel-title>
      </mat-expansion-panel-header>
      <ng-content />
    </mat-expansion-panel>
  `,
  styles: `
    mat-expansion-panel {
      margin-bottom: 8px;
    }
  `,
})
export class CajaComponent {
  readonly titulo = input.required<string>();
  readonly expandida = input(true);
}
