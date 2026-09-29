import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { ActivatedRoute, provideRouter } from '@angular/router';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import {
  ADMIN_REPOSITORY,
  AdminHttpRepository,
  CATALOGO_REPOSITORY,
  CatalogoHttpRepository,
  INICIO_REPOSITORY,
  InicioHttpRepository,
  POPUP_APPIAN_REPOSITORY,
  PopupAppianHttpRepository,
  SESION_REPOSITORY,
  SesionHttpRepository,
} from '@tva/core';

import { Pantalla } from '@tva/core';
import { SesionPage } from './sesion.page';

const sesion = (pantalla: Pantalla) => ({
  clave: 'k',
  usuario: 'u',
  modalidad: 'VA',
  canal: 'GV',
  pantalla_actual: pantalla,
  version_esquema: 1,
  estado: {},
  abierta: true,
  creado: '',
  actualizado: '',
});

describe('SesionPage', () => {
  const create = createComponentFactory({
    component: SesionPage,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      provideRouter([]),
      { provide: ActivatedRoute, useValue: { snapshot: { paramMap: { get: () => 'k' } } } },
      { provide: SESION_REPOSITORY, useClass: SesionHttpRepository },
      { provide: INICIO_REPOSITORY, useClass: InicioHttpRepository },
      { provide: CATALOGO_REPOSITORY, useClass: CatalogoHttpRepository },
      { provide: POPUP_APPIAN_REPOSITORY, useClass: PopupAppianHttpRepository },
      { provide: ADMIN_REPOSITORY, useClass: AdminHttpRepository },
      { provide: ENVIRONMENT, useValue: 'test' },
      {
        provide: ENVIRONMENT_CONFIG,
        useValue: { apiBaseUrl: 'http://t', auth: { tokenStorageKey: 'k' } },
      },
    ],
  });

  function crearYPantalla(pantalla: Pantalla): Spectator<SesionPage> {
    const s = create();
    TestBed.inject(HttpTestingController).expectOne('http://t/sesiones/k/').flush(sesion(pantalla));
    s.detectChanges();
    return s;
  }

  it('renderiza SEGUROS_AHORRO', () => {
    const s = crearYPantalla(Pantalla.SEGUROS_AHORRO);
    expect(s.query('app-seguros-ahorro')).toExist();
  });

  it('renderiza RESUMEN_CONTRATACION', () => {
    const s = crearYPantalla(Pantalla.RESUMEN_CONTRATACION);
    expect(s.query('app-resumen-contratacion')).toExist();
  });

  it('renderiza SISTEMA_CERRADO', () => {
    const s = crearYPantalla(Pantalla.SISTEMA_CERRADO);
    expect(s.query('app-sistema-cerrado')).toExist();
  });
});
