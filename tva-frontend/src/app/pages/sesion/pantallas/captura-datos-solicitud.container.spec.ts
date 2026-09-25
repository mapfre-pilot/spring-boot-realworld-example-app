import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { TvaApiService } from '../../../core/api/tva-api.service';
import { SesionStore } from '../../../core/state/sesion.store';
import { CapturaDatosSolicitudContainer } from './captura-datos-solicitud.container';

const PRODUCTO = {
  commercialProductCode: '00427',
  commercialProductDesc: 'PIAS ELECCION',
  unitLinkedInd: true,
  garantias: [
    {
      codigo: 'FC',
      descripcion: 'Fallecimiento por cualquier causa',
      obligatoria: true,
      seleccionada: true,
    },
    {
      codigo: 'FA',
      descripcion: 'Fallecimiento por accidente',
      obligatoria: false,
      seleccionada: false,
    },
  ],
  periodicidades: ['M', 'T', 'S', 'A'],
  opcionesInversion: [
    { investmentPreferenceCode: 'ES0112835006', descripcion: 'MAPFRE Fondtesoro' },
    { investmentPreferenceCode: 'ES0112835007', descripcion: 'MAPFRE Renta Fija' },
  ],
};

describe('CapturaDatosSolicitudContainer', () => {
  const api = { validarSeccion: jest.fn() };
  const create = createComponentFactory({
    component: CapturaDatosSolicitudContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: TvaApiService, useValue: api },
    ],
  });

  function cargar(store: SesionStore) {
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_DATOS_SOLICITUD',
      estado: {
        productos: [PRODUCTO],
        productoSeleccionado: PRODUCTO,
        codigoProducto: '00427',
        garantias: PRODUCTO.garantias,
        ventaInformada: { opcionesInversion: [] },
        cajas: [],
        avisos: [],
        tomadores: [],
      },
    } as never);
  }

  it('la primera opción seleccionada auto-rellena la prima única', () => {
    api.validarSeccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: 'x', estado: {} })
    );
    const s = create();
    cargar(TestBed.inject(SesionStore));
    s.component.ngOnInit();
    s.component.operacion.controls.primaUnica.setValue(1000);
    s.component.seleccionarOpcion(0, true);
    expect(s.component.importes()[0]?.['unica']).toBe(1000);
    s.detectChanges();
    expect(s.element.innerHTML).toContain('(obligatoria)');
    expect(s.element.innerHTML).toContain('disabled');
  });

  it('postea validar-seccion de operacion al continuar', () => {
    api.validarSeccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: 'x', estado: {} })
    );
    const s = create();
    cargar(TestBed.inject(SesionStore));
    s.component.ngOnInit();
    s.component.continuarSeccion('operacion', s.component.operacion);
    expect(api.validarSeccion).toHaveBeenCalledWith(
      'k',
      'DATOS_DEL_SEGURO',
      'operacion',
      expect.objectContaining({ fechaEfecto: expect.any(String) })
    );
  });
});
