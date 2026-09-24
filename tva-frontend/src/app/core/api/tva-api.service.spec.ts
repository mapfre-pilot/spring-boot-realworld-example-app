import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';

import { ENVIRONMENT, ENVIRONMENT_CONFIG } from '@mapfre-tech/ngx-multienvironment/core';

import { TvaApiService } from './tva-api.service';
import { Pantalla } from '../models/models';

const ENV = { name: 'test', isLocal: true, config: { apiBaseUrl: 'http://test/api' } };

describe('TvaApiService', () => {
  let api: TvaApiService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        { provide: ENVIRONMENT, useValue: 'test' },
        { provide: ENVIRONMENT_CONFIG, useValue: ENV.config },
      ],
    });
    api = TestBed.inject(TvaApiService);
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('GET salud', () => {
    api.salud().subscribe(r => expect(r.status).toBe('ok'));
    const req = http.expectOne('http://test/api/salud/');
    req.flush({ status: 'ok', version: '0.0.1' });
  });

  it('POST inicio/ahorro', () => {
    api.inicioAhorro({ documentoCliente: '00000000T', canal: 'GV' }).subscribe(r => {
      expect(r.pantallaActual).toBe(Pantalla.SEGUROS_AHORRO);
    });
    const req = http.expectOne('http://test/api/inicio/ahorro/');
    expect(req.request.method).toBe('POST');
    req.flush({ claveSesion: 'k', pantallaActual: 'SEGUROS_AHORRO' });
  });

  it('POST accion', () => {
    api
      .accion('k', 'siguiente', { x: 1 })
      .subscribe(r => expect(r.pantallaActual).toBe(Pantalla.FIN));
    const req = http.expectOne('http://test/api/sesiones/k/acciones/siguiente/');
    req.flush({ claveSesion: 'k', pantallaActual: 'FIN', avisos: [], estado: {} });
  });

  it('GET clientes con parámetro documento', () => {
    api.clientes('00000000T').subscribe();
    const req = http.expectOne(r => r.url === 'http://test/api/clientes/');
    expect(req.request.params.get('documento')).toBe('00000000T');
    req.flush({});
  });
});
