import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY, SESION_REPOSITORY, SesionStore } from '@tva/core';
import { AppianPopupService } from '../../../../core/infra/appian/appian-popup.service';
import { CapturaTomador2Container } from './captura-tomador2.container';

describe('CapturaTomador2Container', () => {
  const api = { validarSeccion: jest.fn(), catalogo: jest.fn() };
  const create = createComponentFactory({
    component: CapturaTomador2Container,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
      { provide: CATALOGO_REPOSITORY, useValue: api },
      { provide: AppianPopupService, useValue: { abrir: jest.fn() } },
    ],
  });

  it('renderiza el formulario del tomador y valida contra la caja TOMADOR2', () => {
    api.catalogo.mockReturnValue(of({ valores: [] }));
    api.validarSeccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: 'CAPTURA_TOMADOR2', estado: {} })
    );
    const s = create();
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_TOMADOR2',
      estado: { tomadores: [{}, {}], cajas: [], avisos: [] },
    } as never);
    s.detectChanges();
    expect(s.query('app-tomador-form')).toBeTruthy();
    s.component.continuar('mediosContacto', s.component.formularios.mediosContacto, {});
    expect(api.validarSeccion).toHaveBeenCalledWith(
      'k',
      'CAPTURA_DATOS_TOMADOR2',
      'mediosContacto',
      expect.anything()
    );
  });
});
