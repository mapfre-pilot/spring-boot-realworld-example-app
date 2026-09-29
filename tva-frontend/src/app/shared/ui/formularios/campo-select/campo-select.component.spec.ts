import { FormControl } from '@angular/forms';
import { By } from '@angular/platform-browser';
import { MatFormField } from '@angular/material/form-field';
import { createComponentFactory } from '@ngneat/spectator/jest';

import { CampoSelectComponent } from './campo-select.component';

describe('CampoSelectComponent', () => {
  const create = createComponentFactory({ component: CampoSelectComponent });

  it('muestra la etiqueta y las opciones del mat-select', () => {
    const s = create({
      props: {
        control: new FormControl('M'),
        etiqueta: 'Periodicidad',
        subscriptSizing: 'dynamic',
        opciones: [
          { valor: 'M', etiqueta: 'Mensual' },
          { valor: 'A', etiqueta: 'Anual' },
        ],
      },
    });
    expect(s.query('mat-label')).toHaveText('Periodicidad');
    s.click('mat-select');
    expect(document.querySelectorAll('mat-option')).toHaveLength(2);
    const formField = s.fixture.debugElement.query(By.directive(MatFormField))
      .componentInstance as MatFormField;
    expect(formField.subscriptSizing).toBe('dynamic');
  });
});
