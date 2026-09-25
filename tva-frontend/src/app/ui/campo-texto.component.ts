/** Wrapper sobre mat-form-field de texto — equivale a rule!MU_TextField. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'app-campo-texto',
  imports: [MatFormFieldModule, MatInputModule, ReactiveFormsModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <mat-form-field appearance="outline" class="campo">
      <mat-label>{{ etiqueta() }}</mat-label>
      <input matInput [formControl]="control()" [type]="tipo()" [placeholder]="placeholder()" />
      @if (control().invalid && control().touched) {
        <mat-error>Valor obligatorio o inválido</mat-error>
      }
    </mat-form-field>
  `,
  styles: `
    .campo {
      width: 100%;
    }
  `,
})
export class CampoTextoComponent {
  readonly control = input.required<FormControl>();
  readonly etiqueta = input.required<string>();
  readonly tipo = input('text');
  readonly placeholder = input('');
}
