/** Wrapper sobre mat-select — equivale a rule!MU_Dropdown. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';

export interface Opcion {
  valor: string;
  etiqueta: string;
}

@Component({
  selector: 'app-campo-select',
  imports: [MatFormFieldModule, MatSelectModule, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-form-field appearance="outline" class="campo">
      <mat-label>{{ etiqueta() }}</mat-label>
      <mat-select [formControl]="control()">
        @for (op of opciones(); track op.valor) {
          <mat-option [value]="op.valor">{{ op.etiqueta }}</mat-option>
        }
      </mat-select>
      @if (control().invalid && control().touched) {
        <mat-error>Seleccione una opción</mat-error>
      }
    </mat-form-field>
  `,
  styles: `
    .campo {
      width: 100%;
    }
  `,
})
export class CampoSelectComponent {
  readonly control = input.required<FormControl>();
  readonly etiqueta = input.required<string>();
  readonly opciones = input.required<Opcion[]>();
}
