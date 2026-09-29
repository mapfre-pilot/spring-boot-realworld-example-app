import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY, SesionStore } from '@tva/core';
import { ResultadoFirmaContainer } from './resultado-firma.container';

describe('ResultadoFirmaContainer', () => {
  const api = { ejecutarAccion: jest.fn() };
  const create = createComponentFactory({
    component: ResultadoFirmaContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
    ],
  });

  it('muestra el resultado y "Finalizar" ejecuta siguiente', () => {
    api.ejecutarAccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: 'FIN', estado: {} })
    );
    const s = create();
    TestBed.inject(SesionStore).sesion.set({
      clave: 'k',
      pantalla_actual: 'RESULTADO_FIRMA',
      estado: { firma: { resultado: 'OK' } },
    } as never);
    s.detectChanges();
    expect(s.query('pre')).toHaveText('OK');
    s.click('button');
    expect(api.ejecutarAccion).toHaveBeenCalledWith('k', 'siguiente', expect.anything());
  });
});
