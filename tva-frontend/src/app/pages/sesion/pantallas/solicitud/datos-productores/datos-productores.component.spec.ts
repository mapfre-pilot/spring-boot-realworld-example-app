import { FormBuilder } from '@angular/forms';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { crearFormulariosSolicitud } from '../../../../../core/application/forms/solicitud-forms';
import { DatosProductoresComponent } from './datos-productores.component';

describe('DatosProductoresComponent', () => {
  const create = createComponentFactory(DatosProductoresComponent);

  it('emite continuar y renderiza el formulario', () => {
    const form = crearFormulariosSolicitud(new FormBuilder().nonNullable).productores;
    const s: Spectator<DatosProductoresComponent> = create({ props: { form } });
    const spy = jest.fn();
    s.component.continuar.subscribe(spy);
    s.component.continuar.emit();
    expect(spy).toHaveBeenCalled();
    expect(s.component.form()).toBe(form);
  });
});
