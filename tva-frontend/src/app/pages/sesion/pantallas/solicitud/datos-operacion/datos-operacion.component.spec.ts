import { FormBuilder } from '@angular/forms';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { crearFormulariosSolicitud } from '../../../../../core/application/forms/solicitud-forms';
import { DatosOperacionComponent } from './datos-operacion.component';

describe('DatosOperacionComponent', () => {
  const create = createComponentFactory(DatosOperacionComponent);

  it('sincroniza la señal valor con el formulario', () => {
    const form = crearFormulariosSolicitud(new FormBuilder().nonNullable).operacion;
    const s: Spectator<DatosOperacionComponent> = create({
      props: { form, tiposDuracion: [], periodicidades: [] },
    });
    s.component.ngOnInit();
    expect(s.component['valor']()['tipoDuracion']).toBe('ANIOS');
    form.controls.primaUnica.setValue(12000);
    expect(s.component['valor']()['primaUnica']).toBe(12000);
  });
});
