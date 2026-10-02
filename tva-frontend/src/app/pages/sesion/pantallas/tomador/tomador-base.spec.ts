import { Directive } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY, SESION_REPOSITORY, SesionStore } from '@tva/core';
import { AppianPopupService } from '../../../../core/infra/appian/appian-popup.service';
import { TomadorBase } from './tomador-base';

@Directive()
class TomadorBaseTest extends TomadorBase {
  readonly cajaId = 'CAPTURA_DATOS_TOMADOR1';
  readonly indiceTomador = 0;
}

const RESP_OK = {
  avisos: [],
  botones: [],
  pantallaActual: 'CAPTURA_TOMADOR1',
  estado: { tomadores: [{}], cajas: [], avisos: [] },
};

describe('TomadorBase', () => {
  const api = {
    validarSeccion: jest.fn().mockReturnValue(of(RESP_OK)),
    catalogo: jest.fn().mockReturnValue(of({ valores: [{ codigo: 'H', descripcion: 'Hombre' }] })),
  };

  function setup() {
    TestBed.resetTestingModule();
    TestBed.configureTestingModule({
      providers: [
        { provide: SESION_REPOSITORY, useValue: api },
        { provide: CATALOGO_REPOSITORY, useValue: api },
        { provide: AppianPopupService, useValue: { abrir: jest.fn() } },
      ],
    });
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_TOMADOR1',
      estado: {
        tomadores: [{}],
        cajas: [{ id: 'CAPTURA_DATOS_TOMADOR1', secciones: [] }],
        avisos: [],
      },
    } as never);
    const base = TestBed.runInInjectionContext(() => new TomadorBaseTest());
    return base;
  }

  it('carga catálogos en ngOnInit', () => {
    const b = setup();
    b.ngOnInit();
    expect(api.catalogo).toHaveBeenCalledWith('sexos');
    expect(b['catalogos']()['sexos']).toEqual([{ valor: 'H', etiqueta: 'Hombre' }]);
  });

  it('continuar marca la sección válida y avanza la expandida', () => {
    const b = setup();
    b['continuar']('datosPersonales', b.datosPersonales);
    expect(api.validarSeccion).toHaveBeenCalledWith(
      'k',
      'CAPTURA_DATOS_TOMADOR1',
      'datosPersonales',
      expect.any(Object)
    );
    expect(b['validas']()['datosPersonales']).toBe(true);
    expect(b['expandida']()).toBe('domicilioHabitual');
  });

  it('continuar con errores marca la sección inválida', () => {
    api.validarSeccion.mockReturnValueOnce(
      of({
        ...RESP_OK,
        avisos: [{ tipo: 'ERROR', seccion: 'CAPTURA_DATOS_TOMADOR1/datosPersonales' }],
      })
    );
    const b = setup();
    b['continuar']('datosPersonales', b.datosPersonales);
    expect(b['validas']()['datosPersonales']).toBe(false);
  });

  it('continuarMedios envía medios propios filtrados + móvil + email', () => {
    const b = setup();
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      pantalla_actual: 'CAPTURA_DATOS_TOMADOR1',
      estado: {
        tomadores: [{ mediosContacto: [{ tipo: 'MOVIL' }, { tipo: 'FAX' }] }],
        cajas: [],
        avisos: [],
      },
    } as never);
    b['mediosContacto'].controls.numero.setValue('600123456');
    b['correo'].controls.contactMethodValue.setValue('a@b.com');
    b['continuarMedios']();
    const medios = api.validarSeccion.mock.calls.at(-1)?.[3] as never as { tipo: string }[];
    expect(medios.map(m => m.tipo)).toEqual(['FAX', 'MOVIL', 'EMAIL']);
  });

  it('continuarRepresentante envía null sin representante', () => {
    const b = setup();
    b['hayRepresentante'].set(false);
    b['continuarRepresentante']();
    expect(api.validarSeccion.mock.calls.at(-1)?.[3] as never).toEqual({
      legalRepresentative: null,
    });
  });
});
