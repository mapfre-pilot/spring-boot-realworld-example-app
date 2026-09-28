import { FormControl } from '@angular/forms';
import { createComponentFactory } from '@ngneat/spectator/jest';

import { CampoSelectComponent } from './campo-select.component';

describe('CampoSelectComponent', () => {
  const create = createComponentFactory({ component: CampoSelectComponent });

  it('muestra la etiqueta y las opciones del mat-select', () => {
    const s = create({
      props: {
        control: new FormControl('M'),
        etiqueta: 'Periodicidad',
        opciones: [
          { valor: 'M', etiqueta: 'Mensual' },
          { valor: 'A', etiqueta: 'Anual' },
        ],
      },
    });
    expect(s.query('mat-label')).toHaveText('Periodicidad');
    s.click('mat-select');
    expect(document.querySelectorAll('mat-option')).toHaveLength(2);
  });
});
