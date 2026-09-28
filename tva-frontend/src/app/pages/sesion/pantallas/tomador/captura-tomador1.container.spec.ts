import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY, SESION_REPOSITORY, SesionStore } from '@tva/core';
import { AppianPopupService } from '../../../ui/appian/appian-popup.service';
import { CapturaTomador1Container } from './captura-tomador1.container';

describe('CapturaTomador1Container', () => {
  const api = { validarSeccion: jest.fn(), catalogo: jest.fn() };
  const create = createComponentFactory({
    component: CapturaTomador1Container,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
      { provide: CATALOGO_REPOSITORY, useValue: api },
      { provide: AppianPopupService, useValue: { abrir: jest.fn() } },
    ],
  });

  it('postea validar-seccion con el payload esperado al continuar datos personales', () => {
    api.catalogo.mockReturnValue(of({ valores: [] }));
    api.validarSeccion.mockReturnValue(
      of({
        avisos: [],
        botones: [],
        pantallaActual: 'CAPTURA_TOMADOR1',
        estado: { tomadores: [], cajas: [], avisos: [] },
      })
    );
    const s = create();
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_TOMADOR1',
      estado: { tomadores: [{}], cajas: [], avisos: [] },
    } as never);
    s.component.datosPersonales.controls.documentId.setValue('00000000T');
    s.component.datosPersonales.controls.nombre.setValue('Juan');
    s.component.continuar('datosPersonales', s.component.datosPersonales);
    expect(api.validarSeccion).toHaveBeenCalledWith(
      'k',
      'CAPTURA_DATOS_TOMADOR1',
      'datosPersonales',
      expect.objectContaining({ documentId: '00000000T', nombre: 'Juan' })
    );
  });

  it('botones de requisitos deshabilitados hasta validar datos personales', () => {
    api.catalogo.mockReturnValue(of({ valores: [] }));
    const s = create();
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_TOMADOR1',
      estado: { tomadores: [{}], cajas: [], avisos: [] },
    } as never);
    s.detectChanges();
    const botones = s.element.querySelectorAll('.requisito button');
    expect(botones.length).toBe(3);
    botones.forEach(b => expect((b as HTMLButtonElement).disabled).toBe(true));
  });
});
