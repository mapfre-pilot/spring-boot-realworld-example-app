import { FormBuilder } from '@angular/forms';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { crearFormulariosSolicitud } from '../../../../../core/application/forms/solicitud-forms';
import { DomiciliacionesComponent } from './domiciliaciones.component';

describe('DomiciliacionesComponent', () => {
  const create = createComponentFactory(DomiciliacionesComponent);

  it('refleja requierePrestaciones en la señal', () => {
    const form = crearFormulariosSolicitud(new FormBuilder().nonNullable).domiciliaciones;
    const s: Spectator<DomiciliacionesComponent> = create({ props: { form } });
    s.component.ngOnInit();
    expect(s.component['requierePrestaciones']()).toBe(false);
    form.controls.requierePrestaciones.setValue(true);
    expect(s.component['requierePrestaciones']()).toBe(true);
  });
});
