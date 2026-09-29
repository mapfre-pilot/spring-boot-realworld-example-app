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

  it('muestra la pista y el sufijo opcionales', () => {
    const s = create({
      props: {
        control: new FormControl(25),
        etiqueta: 'Aportación',
        pista: 'Importe de la aportación',
        sufijo: '€',
      },
    });
    expect(s.query('mat-hint')).toHaveText('Importe de la aportación');
    expect(s.query('[matTextSuffix]')).toHaveText('€');
  });
});
