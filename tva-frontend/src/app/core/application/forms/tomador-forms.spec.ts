import { FormBuilder } from '@angular/forms';

import { crearFormulariosTomador } from './tomador-forms';

describe('tomador-forms', () => {
  const fb = new FormBuilder().nonNullable;
  const f = crearFormulariosTomador(fb);

  it('valida el documento de identidad', () => {
    const doc = f.datosPersonales.controls.documentId;
    doc.setValue('');
    expect(doc.errors?.['required']).toBeTruthy();
    doc.setValue('XXXX');
    expect(doc.errors?.['documento']).toBe(true);
    doc.setValue('12345678Z');
    expect(doc.errors).toBeNull();
  });

  it('valida código postal de 5 dígitos y móvil de 9', () => {
    const cp = f.domicilioHabitual.controls.codigoPostal;
    cp.setValue('123');
    expect(cp.errors?.['pattern']).toBeTruthy();
    cp.setValue('28001');
    expect(cp.errors).toBeNull();
    const num = f.mediosContacto.controls.numero;
    num.setValue('600');
    expect(num.errors?.['pattern']).toBeTruthy();
    num.setValue('600123456');
    expect(num.errors).toBeNull();
  });

  it('el correo exige formato email', () => {
    const c = f.correo.controls.contactMethodValue;
    c.setValue('mal');
    expect(c.errors?.['email']).toBeTruthy();
    c.setValue('a@b.com');
    expect(c.errors).toBeNull();
  });
});
