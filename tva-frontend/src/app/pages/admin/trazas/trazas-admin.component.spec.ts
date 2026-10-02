import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';

import { TrazasAdminComponent } from './trazas-admin.component';

describe('TrazasAdminComponent', () => {
  const create = createComponentFactory(TrazasAdminComponent);

  it('emite la clave del filtro al buscar', () => {
    const s: Spectator<TrazasAdminComponent> = create({ props: { trazas: [] } });
    const spy = jest.fn();
    s.component.buscar.subscribe(spy);
    s.component.trazaForm.controls.clave.setValue('abc');
    s.component['buscarTrazas']();
    expect(spy).toHaveBeenCalledWith('abc');
  });

  it('muestra estado vacío sin trazas', () => {
    const s: Spectator<TrazasAdminComponent> = create({ props: { trazas: [] } });
    expect(s.query('app-estado-vacio')).toBeTruthy();
  });
});
