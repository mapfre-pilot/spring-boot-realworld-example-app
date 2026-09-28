/** Módulos Material compartidos — para componentes con 3+ módulos. */
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatRadioModule } from '@angular/material/radio';
import { MatDialogModule } from '@angular/material/dialog';

export const MATERIAL = [
  MatButtonModule,
  MatCardModule,
  MatIconModule,
  MatInputModule,
  MatCheckboxModule,
  MatSlideToggleModule,
  MatFormFieldModule,
  MatTooltipModule,
  MatRadioModule,
  MatDialogModule,
] as const;
