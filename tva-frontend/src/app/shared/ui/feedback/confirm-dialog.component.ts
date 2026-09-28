/** Diálogo de confirmación de la botonera (header/message/ok/cancel). */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-confirm-dialog',
  imports: [MatDialogModule, MatButtonModule],
  templateUrl: './confirm-dialog.component.html',
  styleUrl: './confirm-dialog.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ConfirmDialogComponent {
  readonly data = inject<{ header: string; message: string; ok: string; cancel: string }>(
    MAT_DIALOG_DATA
  );
  readonly ref = inject(MatDialogRef<ConfirmDialogComponent>);
}
