import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { CATALOGO_REPOSITORY, SESION_REPOSITORY, SesionStore } from '@tva/core';
import { SeleccionProductoAhorroContainer } from './seleccion-producto-ahorro.container';

describe('SeleccionProductoAhorroContainer', () => {
  const api = { ejecutarAccion: jest.fn(), productos: jest.fn() };
  const create = createComponentFactory({
    component: SeleccionProductoAhorroContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
      { provide: CATALOGO_REPOSITORY, useValue: api },
    ],
  });

  const estado = {
    productos: [
      {
        commercialProductCode: '00427',
        commercialProductDesc: 'PIAS ELECCION',
        unitLinkedInd: true,
      },
    ],
    perfilUsuario: { nuuma: 'OP1' },
  };

  it('renderiza la tarjeta y "Contratación" lanza seleccionar-modalidad', () => {
    api.ejecutarAccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: '', estado: {} })
    );
    TestBed.inject(SesionStore).sesion.set({
      clave: 'k',
      pantalla_actual: 'SELECCION_PRODUCTO_AHORRO',
      estado,
    } as never);
    const s = create();
    s.detectChanges();
    expect(s.queryAll('mat-card.tarjeta')).toHaveLength(1);
    s.click('mat-card.tarjeta button');
    expect(api.ejecutarAccion).toHaveBeenCalledWith(
      'k',
      'seleccionar-modalidad',
      expect.objectContaining({ productCode: '00427' })
    );
  });

  it('muestra el mensaje de vacío sin productos', () => {
    api.productos.mockReturnValue(of({ products: [] }));
    TestBed.inject(SesionStore).sesion.set({
      clave: 'k',
      pantalla_actual: 'SELECCION_PRODUCTO_AHORRO',
      estado: { productos: [], perfilUsuario: {} },
    } as never);
    const s = create();
    s.detectChanges();
    expect(s.query('p')).toHaveText('no ha devuelvo ningún producto');
  });
});
