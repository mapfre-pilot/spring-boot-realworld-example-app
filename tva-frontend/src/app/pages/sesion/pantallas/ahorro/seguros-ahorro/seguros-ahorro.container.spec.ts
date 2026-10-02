import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY, SesionStore } from '@tva/core';
import { SegurosAhorroContainer } from './seguros-ahorro.container';

registerLocaleData(localeEs);

describe('SegurosAhorroContainer', () => {
  const api = { ejecutarAccion: jest.fn() };
  const create = createComponentFactory({
    component: SegurosAhorroContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
    ],
  });

  const estadoConPropuesta = {
    modoFuncionamiento: 'VA',
    perfilUsuario: { funcionalidades: [4045], nuuma: 'OP1' },
    tomadores: [],
    cajas: [],
    avisos: [],
    responseProposal: {
      contractingProposal: {
        proposalId: 'PROP-0001',
        insurancesApplication: [
          {
            commercialProductCode: '00447',
            commercialProductName: 'Dividendo Vida II',
            investmentOptions: [{ uniqueContributionAmn: 12000, periodicContributionAmn: 0 }],
            statusDesc: null,
          },
        ],
      },
    },
  };

  function sesion(estado: Record<string, unknown>) {
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      modalidad: 'VA',
      pantalla_actual: 'SEGUROS_AHORRO',
      estado,
    } as never);
  }

  it('muestra la fila de la propuesta y ejecuta seleccionar-modalidad al capturar', () => {
    api.ejecutarAccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: '', estado: {} })
    );
    const s = create();
    sesion(estadoConPropuesta);
    s.detectChanges();
    expect(s.query('tbody tr')).toBeTruthy();
    expect(s.query('tbody')).toHaveText('00447 - Dividendo Vida II');
    s.click('tbody button');
    expect(api.ejecutarAccion).toHaveBeenCalledWith(
      'k',
      'seleccionar-modalidad',
      expect.objectContaining({ productCode: '00447' })
    );
  });

  it('muestra el estado vacío sin aplicaciones', () => {
    const s = create();
    sesion({ ...estadoConPropuesta, responseProposal: { contractingProposal: {} } });
    s.detectChanges();
    expect(s.query('tbody')).toBeNull();
    expect(s.query('app-caja')).toHaveText('No hay seguros de ahorro en la propuesta.');
  });
});
