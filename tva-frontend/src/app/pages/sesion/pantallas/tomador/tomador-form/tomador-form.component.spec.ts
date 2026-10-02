import { FormBuilder } from '@angular/forms';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { crearFormulariosTomador } from '../../../../../core/application/forms/tomador-forms';
import { RequisitoTomador, TomadorFormComponent } from './tomador-form.component';

describe('TomadorFormComponent', () => {
  const create = createComponentFactory(TomadorFormComponent);
  const props = () => ({
    grupos: crearFormulariosTomador(new FormBuilder().nonNullable),
    hayRepresentante: false,
    expandidaId: 'datosPersonales',
    cajaId: 'CAPTURA_DATOS_TOMADOR1',
    catalogos: { sexos: [{ valor: 'H', etiqueta: 'Hombre' }] },
  });

  it('catalogo devuelve las opciones o [] si falta', () => {
    const s: Spectator<TomadorFormComponent> = create({ props: props() });
    expect(s.component['catalogo']('sexos')).toHaveLength(1);
    expect(s.component['catalogo']('inexistente')).toEqual([]);
  });

  it('emite continuar y requisito', () => {
    const s: Spectator<TomadorFormComponent> = create({ props: props() });
    const spC = jest.fn();
    const spR = jest.fn();
    s.component.continuar.subscribe(spC);
    s.component.requisito.subscribe(spR);
    s.component.continuar.emit('fatcaCrs');
    expect(spC).toHaveBeenCalledWith('fatcaCrs');
    const r: RequisitoTomador = { etiqueta: 'x', popup: 'MISV', hecho: false, habilitado: true };
    s.component.requisito.emit(r);
    expect(spR).toHaveBeenCalledWith(r);
  });
});
