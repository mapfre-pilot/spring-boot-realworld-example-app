import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { SesionStore } from './sesion.store';
import { Pantalla } from '../models/models';

const SESION = {
  clave: 'k',
  usuario: 'u',
  modalidad: 'VA',
  canal: 'GV',
  pantalla_actual: Pantalla.SEGUROS_AHORRO,
  version_esquema: 1,
  estado: {},
  abierta: true,
  creado: '',
  actualizado: '',
};

describe('SesionStore', () => {
  let store: SesionStore;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: ENVIRONMENT, useValue: 'test' },
        { provide: ENVIRONMENT_CONFIG, useValue: { apiBaseUrl: 'http://t' } },
      ],
    });
    store = TestBed.inject(SesionStore);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('cargar y ejecutar acción actualiza pantalla', () => {
    store.cargar('k').subscribe();
    http.expectOne('http://t/sesiones/k/').flush(SESION);
    expect(store.pantallaActual()).toBe(Pantalla.SEGUROS_AHORRO);

    store.ejecutar('siguiente').subscribe();
    http.expectOne('http://t/sesiones/k/acciones/siguiente/').flush({
      claveSesion: 'k',
      pantallaActual: Pantalla.CAPTURA_DATOS_SOLICITUD,
      avisos: [],
      estado: {},
    });
    expect(store.pantallaActual()).toBe(Pantalla.CAPTURA_DATOS_SOLICITUD);
  });
});
