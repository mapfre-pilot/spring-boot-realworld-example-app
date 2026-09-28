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

  it('continuarMedios reconstruye la lista: filas vacías previas no persisten', () => {
    api.catalogo.mockReturnValue(of({ valores: [] }));
    api.validarSeccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: 'CAPTURA_TOMADOR2', estado: {} })
    );
    const s = create();
    TestBed.inject(SesionStore).sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_TOMADOR2',
      estado: {
        tomadores: [{}, { mediosContacto: [{ tipo: 'MOVIL' }, { tipo: 'EMAIL' }] }],
        cajas: [],
        avisos: [],
      },
    } as never);
    s.detectChanges();
    const comp = s.component as unknown as { continuarMedios(): void };
    comp.continuarMedios();
    expect(api.validarSeccion).toHaveBeenLastCalledWith(
      'k',
      'CAPTURA_DATOS_TOMADOR2',
      'mediosContacto',
      []
    );
    s.component.formularios.mediosContacto.patchValue({
      tipo: 'MOVIL',
      prefijo: '+34',
      numero: '600123456',
    });
    s.component.formularios.correo.patchValue({ contactMethodValue: 'a@b.es' });
    comp.continuarMedios();
    expect(api.validarSeccion).toHaveBeenLastCalledWith(
      'k',
      'CAPTURA_DATOS_TOMADOR2',
      'mediosContacto',
      [
        { tipo: 'MOVIL', prefijo: '+34', numero: '600123456', contactMethodValue: '600123456' },
        { tipo: 'EMAIL', contactMethodValue: 'a@b.es' },
      ]
    );
  });
});
