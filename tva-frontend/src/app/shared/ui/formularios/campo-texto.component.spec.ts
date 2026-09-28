import { FormControl } from '@angular/forms';
import { createComponentFactory } from '@ngneat/spectator/jest';

import { CampoTextoComponent } from './campo-texto.component';

describe('CampoTextoComponent', () => {
  const create = createComponentFactory({ component: CampoTextoComponent });

  it('muestra la etiqueta y enlaza el FormControl', () => {
    const control = new FormControl('inicial');
    const s = create({ props: { control, etiqueta: 'Nombre' } });
    expect(s.query('mat-label')).toHaveText('Nombre');
    s.typeInElement('nuevo valor', 'input');
    expect(control.value).toBe('nuevo valor');
  });
});
