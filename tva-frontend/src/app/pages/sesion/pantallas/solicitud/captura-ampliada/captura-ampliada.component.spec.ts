import { FormBuilder } from '@angular/forms';
import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { crearFormulariosSolicitud } from '../../../../../core/application/forms/solicitud-forms';
import { CapturaAmpliadaComponent } from './captura-ampliada.component';

describe('CapturaAmpliadaComponent', () => {
  const f = crearFormulariosSolicitud(new FormBuilder().nonNullable);
  const create = createComponentFactory(CapturaAmpliadaComponent);
  const props = () => ({
    datosContacto: f.datosContacto,
    asegurado: f.asegurado,
    beneficiarios: f.beneficiarios,
    nota: f.nota,
    tiposBeneficiario: [],
    expandidaId: 'datosContacto',
    ampliada: false,
  });

  it('sincroniza esTomador y beneficiarioTipo con los formularios', () => {
    const s: Spectator<CapturaAmpliadaComponent> = create({ props: props() });
    s.component.ngOnInit();
    expect(s.component['esTomador']()).toBe(true);
    expect(s.component['beneficiarioTipo']()).toBe('HEREDEROS');
    f.asegurado.controls.esTomador.setValue(false);
    expect(s.component['esTomador']()).toBe(false);
    f.beneficiarios.controls.tipo.setValue('OTROS');
    expect(s.component['beneficiarioTipo']()).toBe('OTROS');
  });
});
