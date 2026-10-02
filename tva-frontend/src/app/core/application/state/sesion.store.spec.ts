import { TestBed } from '@angular/core/testing';

import { ACCION_POR_BOTON, SesionStore } from './sesion.store';

describe('SesionStore', () => {
  let store: SesionStore;
  beforeEach(() => {
    TestBed.resetTestingModule();
    store = TestBed.inject(SesionStore);
  });

  it('aplica una Sesion completa y computados derivados', () => {
    store.aplicarRespuesta({
      clave: 'k',
      modalidad: 'VIA',
      pantalla_actual: 'TOMADOR',
      estado: { avisos: [{ texto: 'a' }] },
      botones: [{ id: 'x' }],
    } as never);
    expect(store.claveSesion()).toBe('k');
    expect(store.pantallaActual()).toBe('TOMADOR');
    expect(store.modalidad()).toBe('VIA');
    expect(store.avisos()).toHaveLength(1);
    expect(store.botones()).toHaveLength(1);
  });

  it('aplica una AccionResponse incremental conservando la sesión', () => {
    store.sesion.set({ clave: 'k', pantalla_actual: 'A', estado: {} } as never);
    store.aplicarRespuesta({
      pantallaActual: 'B',
      estado: { foo: 1 },
      avisos: [],
      botones: [],
    } as never);
    expect(store.pantallaActual()).toBe('B');
    expect(store.sesion()?.estado).toEqual({ foo: 1, avisos: [] });
  });

  it('ignora la parte de sesión en AccionResponse si no hay sesión previa', () => {
    store.aplicarRespuesta({
      pantallaActual: 'B',
      estado: {},
      avisos: [],
      botones: [{ id: 'b' }],
    } as never);
    expect(store.sesion()).toBeNull();
    expect(store.botones()).toHaveLength(1);
  });

  it('limpiar reinicia señales', () => {
    store.sesion.set({} as never);
    store.botones.set([{ id: 'x' } as never]);
    store.datosPendientes.set({ a: 1 });
    store.limpiar();
    expect(store.sesion()).toBeNull();
    expect(store.botones()).toEqual([]);
    expect(store.datosPendientes()).toEqual({});
  });

  it('ACCION_POR_BOTON mapea los botones conocidos', () => {
    expect(ACCION_POR_BOTON['atras']).toBe('anterior');
    expect(ACCION_POR_BOTON['recalcular']).toBe('recalcular-rentas');
    expect(ACCION_POR_BOTON['firmar']).toBe('firmar');
  });
});
