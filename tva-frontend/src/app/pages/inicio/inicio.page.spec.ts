import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { provideRouter } from '@angular/router';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { InicioPage } from './inicio.page';

describe('InicioPage', () => {
  const create = createComponentFactory({
    component: InicioPage,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      provideRouter([]),
      { provide: ENVIRONMENT, useValue: 'test' },
      {
        provide: ENVIRONMENT_CONFIG,
        useValue: { apiBaseUrl: 'http://t', auth: { tokenStorageKey: 'k' } },
      },
    ],
  });

  function crear(): Spectator<InicioPage> {
    const s = create();
    TestBed.inject(HttpTestingController)
      .expectOne(r => r.url === 'http://t/productos/')
      .flush({ products: [] });
    return s;
  }

  it('proposalId solo editable en VA', () => {
    const s = crear();
    const prop = s.component.form.controls.proposalId;
    expect(prop.disabled).toBe(true);
    s.component.form.controls.indFunctionMode.setValue('VA');
    expect(prop.enabled).toBe(true);
    prop.setValue('');
    expect(prop.hasError('required')).toBe(true);
    s.component.form.controls.indFunctionMode.setValue('VIA');
    expect(prop.disabled).toBe(true);
  });

  it('renderiza la lista de errores del backend', () => {
    const s = crear();
    s.component.errores.set(['El campo companyId no puede ser nulo']);
    s.detectChanges();
    expect(s.element.textContent).toContain('Se han encontrado ERRORES');
    expect(s.element.textContent).toContain('El campo companyId no puede ser nulo');
  });

  it('VA permite añadir filas de inversión', () => {
    const s = crear();
    s.component.nuevaOpcion();
    expect(s.component.investment.length).toBe(1);
    s.component.borrarOpcion(0);
    expect(s.component.investment.length).toBe(0);
  });
});

describe('policyHolders según Perfilado', () => {
  const create2 = createComponentFactory({
    component: InicioPage,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      provideRouter([]),
      { provide: ENVIRONMENT, useValue: 'test' },
      {
        provide: ENVIRONMENT_CONFIG,
        useValue: { apiBaseUrl: 'http://t', auth: { tokenStorageKey: 'k' } },
      },
    ],
  });

  it('envía testData.convenience solo cuando Perfilado está marcado', () => {
    const s = create2();
    const http = TestBed.inject(HttpTestingController);
    http.expectOne(r => r.url === 'http://t/productos/').flush({ products: [] });
    s.component.form.controls.perfilado.setValue(false);
    s.component.iniciar();
    let req = http.expectOne(r => r.url === 'http://t/inicio/ahorro/');
    expect(req.request.body.policyHolders).toEqual([{}]);
    req.flush({ errors: [] }, { status: 400, statusText: 'Bad Request' });
    s.component.form.controls.perfilado.setValue(true);
    s.component.iniciar();
    req = http.expectOne(r => r.url === 'http://t/inicio/ahorro/');
    expect(req.request.body.policyHolders).toEqual([
      {
        testData: {
          convenience: {
            profileCode: 'ME',
            profileDesc: 'Medios',
            signatureStatus: 'FI',
            expirationDate: '2028-01-17',
          },
        },
      },
    ]);
    req.flush({ errors: [] }, { status: 400, statusText: 'Bad Request' });
  });
});
