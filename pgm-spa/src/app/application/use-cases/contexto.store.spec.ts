import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { PGM_REPOSITORY } from '../ports/pgm.repository';
import { ContextoStore } from './contexto.store';

describe('ContextoStore', () => {
  const contexto = {
    usuario: 'u1', nombre: 'Usuario Uno', perfiles: ['PGM_USUARIO'], perfilSgc30: null, estructura: null,
    visibilidades: { inicio: true, gestionesSgc30: false },
  };

  function crear(repo: { contexto: () => unknown }) {
    TestBed.configureTestingModule({ providers: [{ provide: PGM_REPOSITORY, useValue: repo }] });
    return TestBed.inject(ContextoStore);
  }

  it('aplica las visibilidades que entrega el BFF sin recalcularlas', async () => {
    const store = crear({ contexto: () => of(contexto) });
    await store.cargar();
    expect(store.cargado()).toBe(true);
    expect(store.puede('inicio')).toBe(true);
    expect(store.puede('gestionesSgc30')).toBe(false);
    expect(store.puede('cuadroMando')).toBe(false);
    expect(store.nuuma()).toBeNull();
  });

  it('expone el error cuando el BFF no responde', async () => {
    const store = crear({ contexto: () => throwError(() => new Error('BFF no disponible')) });
    await store.cargar();
    expect(store.cargado()).toBe(false);
    expect(store.error()).toBe('BFF no disponible');
  });
});
