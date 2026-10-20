import { Spectator, createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';
import { provideRouter } from '@angular/router';
import { PGM_REPOSITORY, PgmRepository } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Lanzadera } from '../../domain/models/api.models';
import { MenuLanzaderasComponent } from './menu-lanzaderas.component';

const LANZADERAS: Lanzadera[] = [
  {
    codigo: 'NSE',
    nombre: 'Tarificación y emisión',
    destino: 'NSE',
    ramo: 'AUTOS',
    url: 'https://nse.invalid',
    requiereNuuma: false,
  },
  {
    codigo: 'SGC30',
    nombre: 'Gestión comercial',
    destino: 'SGC30',
    ramo: null,
    url: 'https://sgc.invalid',
    requiereNuuma: true,
  },
];

describe('MenuLanzaderasComponent', () => {
  let spectator: Spectator<MenuLanzaderasComponent>;
  const lanzaderas = jest.fn(() => of({ total: 2, items: LANZADERAS }));
  const factory = createComponentFactory({
    component: MenuLanzaderasComponent,
    providers: [
      provideRouter([]),
      { provide: PGM_REPOSITORY, useValue: { lanzaderas } as unknown as PgmRepository },
      { provide: ContextoStore, useValue: { nuuma: () => null } as unknown as ContextoStore },
    ],
  });

  beforeEach(() => {
    spectator = factory({ props: { titulo: 'N. Producción', ruta: '/nueva-produccion' } });
  });

  it('agrupa las lanzaderas del ramo en tarjetas por destino y bloquea las que requieren NUUMA', async () => {
    await spectator.fixture.whenStable();
    spectator.detectChanges();
    expect(lanzaderas).toHaveBeenCalledWith('AUTOS');
    const tarjetas = spectator.queryAll('.tarjeta');
    expect(tarjetas.length).toBe(2);
    expect(tarjetas[0].textContent).toContain('NSE · Nuevo Sistema de Emisión');
    expect(spectator.query('a.enlace')?.getAttribute('href')).toBe('https://nse.invalid');
    expect(spectator.query('.enlace.bloqueado')?.textContent).toContain('Gestión comercial');
  });

  it('cambia de ramo y emite cerrar', async () => {
    const cerrado = jest.fn();
    spectator.component.cerrar.subscribe(cerrado);
    spectator.click(spectator.queryAll('.ramos button')[2]);
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    expect(lanzaderas).toHaveBeenCalledWith('SALUD');
    spectator.click('.cerrar');
    expect(cerrado).toHaveBeenCalled();
  });
});
