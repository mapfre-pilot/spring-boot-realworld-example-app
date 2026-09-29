import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY, SesionStore } from '@tva/core';
import { R2cCapturaContainer } from './r2c-captura.container';

describe('R2cCapturaContainer', () => {
  const api = { validarSeccion: jest.fn() };
  const create = createComponentFactory({
    component: R2cCapturaContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
    ],
  });

  it('renderiza el formulario y Continuar envía validar-seccion con rentas y tomadores', () => {
    api.validarSeccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: 'R2C_CAPTURA', estado: {} })
    );
    const s = create();
    TestBed.inject(SesionStore).sesion.set({
      clave: 'k',
      pantalla_actual: 'R2C_CAPTURA',
      estado: { rentas: {}, tomadores: [] },
    } as never);
    s.detectChanges();
    expect(s.queryAll('app-campo-texto').length).toBeGreaterThanOrEqual(7);
    s.component.continuar();
    expect(api.validarSeccion).toHaveBeenCalledWith(
      'k',
      'R2C_CAPTURA',
      'captura',
      expect.objectContaining({ tomadores: expect.any(Array) })
    );
  });
});
