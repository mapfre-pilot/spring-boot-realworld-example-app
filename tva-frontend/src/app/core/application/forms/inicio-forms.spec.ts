import { FormBuilder } from '@angular/forms';

import { crearFormularioInicio, crearGrupoInversion } from './inicio-forms';

describe('inicio-forms', () => {
  const fb = new FormBuilder().nonNullable;

  it('crea el formulario con los valores por defecto de VIA', () => {
    const f = crearFormularioInicio(fb);
    expect(f.controls.indFunctionMode.value).toBe('VIA');
    expect(f.controls.companyId.value).toBe('0511');
    expect(f.controls.proposalId.disabled).toBe(true);
    expect(f.invalid).toBe(true); // username requerido
    f.controls.username.setValue('op@mapfre.net');
    expect(f.valid).toBe(true);
  });

  it('crea un grupo de inversión con operationTypeCode S', () => {
    const g = crearGrupoInversion(fb);
    expect(g.controls.operationTypeCode.value).toBe('S');
    expect(g.controls.insuranceOfferInd.value).toBe(false);
  });
});
