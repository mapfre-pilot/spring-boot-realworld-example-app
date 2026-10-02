import { FormBuilder } from '@angular/forms';

import { crearFormulariosSolicitud } from './solicitud-forms';

describe('solicitud-forms', () => {
  const fb = new FormBuilder().nonNullable;
  const f = crearFormulariosSolicitud(fb);

  it('expone todas las secciones', () => {
    for (const id of [
      'productores',
      'operacion',
      'domiciliaciones',
      'datosContacto',
      'asegurado',
      'beneficiarios',
      'nota',
    ]) {
      expect((f as never)[id]).toBeTruthy();
    }
  });

  it('valida el IBAN de recibos', () => {
    const iban = f.domiciliaciones.controls.ibanRecibos;
    iban.setValue('');
    expect(iban.errors?.['required']).toBeTruthy();
    iban.setValue('ES111111');
    expect(iban.errors?.['iban']).toBe(true);
    iban.setValue('ES9121000418450200051332');
    expect(iban.errors).toBeNull();
  });

  it('operación lleva fecha de efecto rellena y tipo ANIOS', () => {
    expect(f.operacion.controls.fechaEfecto.value).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect(f.operacion.controls.tipoDuracion.value).toBe('ANIOS');
  });
});
