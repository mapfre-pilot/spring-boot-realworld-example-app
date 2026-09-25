/** Wrapper sobre mat-form-field de texto — equivale a rule!MU_TextField. */
import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

@Component({
  selector: 'app-campo-texto',
  imports: [MatFormFieldModule, MatInputModule, ReactiveFormsModule],
  templateUrl: './campo-texto.component.html',
  styleUrl: './campo-texto.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CampoTextoComponent {
  readonly control = input.required<FormControl>();
  readonly etiqueta = input.required<string>();
  readonly tipo = input('text');
  readonly placeholder = input('');
}
