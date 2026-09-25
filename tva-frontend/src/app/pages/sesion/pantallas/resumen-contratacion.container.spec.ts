import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY, SesionStore } from '@tva/core';
import { ResumenContratacionContainer } from './resumen-contratacion.container';

registerLocaleData(localeEs);

const ESTADO = {
  codigoProducto: '00427',
  productos: [{ commercialProductCode: '00427', commercialProductDesc: 'PIAS ELECCION' }],
  datosOperacion: {
    primaUnica: 5000,
    fechaEfecto: '2026-10-01',
    ibanRecibos: 'ES9121000418450200051332',
  },
  tomadores: [
    {
      datosPersonales: {
        nombre: 'Ana',
        primerApellido: 'García',
        documentId: '00000000T',
        fechaNacimiento: '1980-01-15',
      },
      mediosContacto: [
        { tipo: 'EMAIL', contactMethodValue: 'ana@test.com' },
        { tipo: 'MOVIL', prefijo: '+34', numero: '600111222' },
      ],
      datosGestionParticipante: { consentimientoProteccionDatos: true },
    },
  ],
  documentosPrecontractuales: [],
  cajas: [],
  avisos: [],
};

describe('ResumenContratacionContainer', () => {
  const api = { ejecutarAccion: jest.fn() };
  const create = createComponentFactory({
    component: ResumenContratacionContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
    ],
  });

  function cargar(store: SesionStore) {
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'RESUMEN_CONTRATACION',
      estado: ESTADO,
    } as never);
  }

  it('muestra producto, prima única formateada y tomador', () => {
    const s = create();
    cargar(TestBed.inject(SesionStore));
    s.detectChanges();
    const html = s.element.innerHTML;
    expect(html).toContain('00427');
    expect(html).toContain('PIAS ELECCION');
    expect(html).toContain('5.000,00');
    expect(html).toContain('Única');
    expect(html).toContain('Ana');
    expect(html).toContain('00000000T');
    expect(html).toContain('ana@test.com');
    expect(html).toContain('Sin documentos');
  });
});
