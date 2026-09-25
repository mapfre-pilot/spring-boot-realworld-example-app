/** Diálogo de confirmación de la botonera (header/message/ok/cancel). */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-confirm-dialog',
  imports: [MatDialogModule, MatButtonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <h2 mat-dialog-title>{{ data.header }}</h2>
    <mat-dialog-content class="mensaje">{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button [mat-dialog-close]="false">{{ data.cancel }}</button>
      <button mat-flat-button color="primary" [mat-dialog-close]="true">{{ data.ok }}</button>
    </mat-dialog-actions>
  `,
  styles: `
    .mensaje {
      white-space: pre-line;
    }
  `,
})
export class ConfirmDialogComponent {
  readonly data = inject<{ header: string; message: string; ok: string; cancel: string }>(
    MAT_DIALOG_DATA
  );
  readonly ref = inject(MatDialogRef<ConfirmDialogComponent>);
}
