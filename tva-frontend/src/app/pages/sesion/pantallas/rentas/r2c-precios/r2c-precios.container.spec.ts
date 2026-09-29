import { registerLocaleData } from '@angular/common';
import localeEs from '@angular/common/locales/es';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';

import { SESION_REPOSITORY, SesionStore } from '@tva/core';
import { R2cPreciosContainer } from './r2c-precios.container';

registerLocaleData(localeEs);

describe('R2cPreciosContainer', () => {
  const api = { ejecutarAccion: jest.fn() };
  const create = createComponentFactory({
    component: R2cPreciosContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: api },
    ],
  });

  const estadoR2c = {
    modoFuncionamiento: 'R2C',
    perfilUsuario: {},
    tomadores: [
      { datosPersonales: { participationPerc: 60 } },
      { datosPersonales: { participationPerc: 40 } },
    ],
    cajas: [],
    avisos: [],
    rentas: {
      importeTotalPrima: 50000,
      periodicidadRenta: 'ANUAL',
      deathCapitalOptions: [{ deathCapitalPremiumPerc: 50 }, { deathCapitalPremiumPerc: 100 }],
      simulaciones: [
        { projectData: { premiumAmn: 50000, incomeAmn: 1415.89, expectedReturnPerc: 2.3 } },
        { projectData: { premiumAmn: 50000, incomeAmn: 1058.17, expectedReturnPerc: 2.41 } },
      ],
      idxSimulacionSeleccionada: null,
      rentaObjetivo: null,
      recalcular: false,
    },
  };

  function sesion(rentas: Record<string, unknown>) {
    const store = TestBed.inject(SesionStore);
    store.sesion.set({
      clave: 'k',
      modalidad: 'R2C',
      pantalla_actual: 'R2C_PRECIOS',
      estado: { ...estadoR2c, rentas },
    } as never);
  }

  it('renderiza las dos opciones y el radio llama actualizar-rentas con idx', () => {
    api.ejecutarAccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: '', estado: {} })
    );
    const s = create();
    sesion(estadoR2c.rentas);
    s.detectChanges();
    expect(s.queryAll('mat-card.opcion')).toHaveLength(2);
    s.click('mat-card.opcion mat-radio-button input');
    expect(api.ejecutarAccion).toHaveBeenCalledWith(
      'k',
      'actualizar-rentas',
      expect.objectContaining({ idxSimulacionSeleccionada: 0 })
    );
  });

  it('el campo renta llama actualizar-rentas con rentaObjetivo', () => {
    api.ejecutarAccion.mockReturnValue(
      of({ avisos: [], botones: [], pantallaActual: '', estado: {} })
    );
    const s = create();
    sesion({ ...estadoR2c.rentas, idxSimulacionSeleccionada: 0 });
    s.detectChanges();
    s.component.rentaControl.setValue(1200);
    s.component.cambiarRenta();
    expect(api.ejecutarAccion).toHaveBeenCalledWith(
      'k',
      'actualizar-rentas',
      expect.objectContaining({ rentaObjetivo: 1200 })
    );
  });
});
