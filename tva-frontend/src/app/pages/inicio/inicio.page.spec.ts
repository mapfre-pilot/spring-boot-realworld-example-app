import { provideHttpClient } from '@angular/common/http';
import { provideRouter } from '@angular/router';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { InicioPage } from './inicio.page';

describe('InicioPage', () => {
  const create = createComponentFactory({
    component: InicioPage,
    providers: [
      provideHttpClient(),
      provideRouter([]),
      { provide: ENVIRONMENT, useValue: 'test' },
      {
        provide: ENVIRONMENT_CONFIG,
        useValue: { apiBaseUrl: 'http://t', auth: { tokenStorageKey: 'k' } },
      },
    ],
  });

  it('formulario requiere documento válido', () => {
    const s: Spectator<InicioPage> = create();
    s.component.form.controls.documentoCliente.setValue('00000000T');
    expect(s.component.form.controls.documentoCliente.valid).toBe(true);
    s.component.form.controls.documentoCliente.setValue('mal');
    expect(s.component.form.controls.documentoCliente.valid).toBe(false);
  });
});
