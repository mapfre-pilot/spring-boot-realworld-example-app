import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { Parametro } from '@tva/core';
import { ParametrosAdminComponent } from './parametros-admin.component';

const P: Parametro = {
  clave: 'K',
  valor: '1',
  tipo: 'str',
  descripcion: '',
  entorno: null,
  actualizado: '',
};

describe('ParametrosAdminComponent', () => {
  const create = createComponentFactory(ParametrosAdminComponent);

  it('renderiza filas y emite guardarValor con clave y valor', () => {
    const s: Spectator<ParametrosAdminComponent> = create({ props: { parametros: [P] } });
    const spy = jest.fn();
    s.component.guardarValor.subscribe(spy);
    s.component['guardar'](P, '9');
    expect(spy).toHaveBeenCalledWith({ p: P, valor: '9' });
  });

  it('muestra el estado vacío sin parámetros', () => {
    const s: Spectator<ParametrosAdminComponent> = create({ props: { parametros: [] } });
    expect(s.query('app-estado-vacio')).toBeTruthy();
    expect(s.query('table')).toBeFalsy();
  });
});
