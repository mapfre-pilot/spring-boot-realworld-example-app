import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { createComponentFactory } from '@ngneat/spectator/jest';

import { SESION_REPOSITORY, SesionStore } from '@tva/core';
import { ModalidadCampaniaContainer } from './modalidad-campania.container';

describe('ModalidadCampaniaContainer', () => {
  const create = createComponentFactory({
    component: ModalidadCampaniaContainer,
    providers: [
      provideHttpClient(),
      provideHttpClientTesting(),
      { provide: SESION_REPOSITORY, useValue: {} },
    ],
  });

  it('renderiza las dos opciones y propaga la modalidad al store', () => {
    const s = create();
    const store = TestBed.inject(SesionStore);
    store.sesion.set({ clave: 'k', pantalla_actual: 'MODALIDAD_CAMPANIA', estado: {} } as never);
    s.detectChanges();
    expect(s.queryAll('mat-radio-button')).toHaveLength(2);
    s.component.form.controls.modalidadCampania.setValue('SIN_CAMPAÑA');
    expect(store.datosPendientes()).toEqual({ modalidadCampania: 'SIN_CAMPAÑA' });
  });
});
