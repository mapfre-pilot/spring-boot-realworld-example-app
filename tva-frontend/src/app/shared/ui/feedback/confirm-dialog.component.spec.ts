import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { createComponentFactory, mockProvider } from '@ngneat/spectator/jest';

import { ConfirmDialogComponent } from './confirm-dialog.component';

describe('ConfirmDialogComponent', () => {
  const create = createComponentFactory({
    component: ConfirmDialogComponent,
    providers: [
      mockProvider(MatDialogRef),
      {
        provide: MAT_DIALOG_DATA,
        useValue: { header: 'Confirmar', message: '¿Seguro?', ok: 'Aceptar', cancel: 'Volver' },
      },
    ],
  });

  it('muestra header, mensaje y los dos botones', () => {
    const s = create();
    expect(s.query('h2')).toHaveText('Confirmar');
    expect(s.query('.mensaje')).toHaveText('¿Seguro?');
    expect(s.queryAll('button')).toHaveLength(2);
    expect(s.queryAll('button')[0]).toHaveText('Volver');
    expect(s.queryAll('button')[1]).toHaveText('Aceptar');
  });
});
