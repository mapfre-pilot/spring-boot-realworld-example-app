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
  templateUrl: './campo-select.component.html',
  styleUrl: './campo-select.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CampoSelectComponent {
  readonly control = input.required<FormControl>();
  readonly etiqueta = input.required<string>();
  readonly opciones = input.required<Opcion[]>();
}
