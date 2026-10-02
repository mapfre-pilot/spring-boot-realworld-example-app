import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { Aviso } from '@tva/core';
import { SeccionComponent } from './seccion.component';

describe('SeccionComponent', () => {
  const create = createComponentFactory(SeccionComponent);

  it('renderiza el check verde cuando es válida', () => {
    const s: Spectator<SeccionComponent> = create({
      props: { titulo: 'Datos personales', seccion: 'C/S', valida: true, avisos: [] },
    });
    expect(s.query('.icono-ok')).toBeTruthy();
  });

  it('renderiza avisos solo de la sección indicada', () => {
    const avisos: Aviso[] = [
      { clase: 1, tipo: 'ERROR', texto: 'err1', mostrarEn: 'SECCION', seccion: 'C/S' },
      { clase: 2, tipo: 'ERROR', texto: 'err2', mostrarEn: 'SECCION', seccion: 'Otra' },
      { clase: 3, tipo: 'ERROR', texto: 'err3', mostrarEn: 'CABECERA', seccion: 'C/S' },
    ];
    const s: Spectator<SeccionComponent> = create({
      props: { titulo: 't', seccion: 'C/S', avisos },
    });
    expect(s.component.avisosSeccion()).toHaveLength(1);
    expect(s.component.avisosSeccion()[0].texto).toBe('err1');
  });

  it('emite continuar al pulsar el botón', () => {
    const s: Spectator<SeccionComponent> = create({ props: { titulo: 't', seccion: 'C/S' } });
    const spy = jest.fn();
    s.component.continuar.subscribe(spy);
    const btn = s.query('button');
    expect(btn).toBeTruthy();
    btn?.click();
    expect(spy).toHaveBeenCalled();
  });

  it('renderiza el aviso ERROR de la sección dentro de app-avisos', () => {
    const s: Spectator<SeccionComponent> = create({
      props: {
        titulo: 't',
        seccion: 'C/s',
        avisos: [{ clase: 1, tipo: 'ERROR', texto: 'X', mostrarEn: 'SECCION', seccion: 'C/s' }],
      },
    });
    expect(s.element.textContent).toContain('X');
  });
});
