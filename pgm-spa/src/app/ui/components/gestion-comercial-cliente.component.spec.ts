import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';
import { of, throwError } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { GestionComercialClienteComponent, TEXTOS_GC } from './gestion-comercial-cliente.component';

const oportunidad = {
  id: 'O-1',
  clienteId: 'C-1',
  tipo: 'VENCIMIENTO',
  ramo: 'AUTOS',
  polizaNumero: 'AUT-1',
  fecha: '2026-11-15',
  descripcion: 'Vto.',
  prioridad: 'ALTA',
  clase: 'COMPLETO',
  usuario: 'NU1',
  entidadCompetencia: 'Allianz',
  prima: 420.5,
  comentarios: 'c',
  anexos: 1,
  contratado: false,
};
const gestion = {
  id: 'G-1',
  clienteId: 'C-1',
  tipo: 'Llamada',
  estado: 'ABIERTA',
  fecha: '2026-10-03T10:30:00',
  descripcion: 'd',
  gestor: 'NU1',
  origen: 'SGC30',
  fechaCaducidad: '2026-12-10',
  probabilidadConversion: 75,
  agendado: true,
  whatsapp: true,
  permisos: ['VIEW'],
};

function repo(overrides: Record<string, unknown> = {}) {
  return {
    oportunidades: jest.fn(() => of({ items: [oportunidad], total: 1 })),
    resumenOportunidades: jest.fn(() =>
      of({ todos: 1, completos: 1, incompletos: 0, presupuestos: 0 }),
    ),
    oportunidad: jest.fn(() =>
      of({
        oportunidad,
        datosGenerales: { 'Fecha de vencimiento': '15/11/2026' },
        datosProducto: {},
        datosRiesgo: {},
        observaciones: [],
        documentos: [],
      }),
    ),
    crearOportunidad: jest.fn(() => of(oportunidad)),
    observarOportunidad: jest.fn(() =>
      of({ id: 'OB', fecha: '', fechaActualizacion: null, texto: 't', usuario: 'NU1' }),
    ),
    eliminarObservacionOportunidad: jest.fn(() => of(void 0)),
    actividadComercial: jest.fn(() => of({ items: [], total: 0 })),
    crearActividad: jest.fn(),
    catalogoComercial: jest.fn(() => of({ tipo: 'NIVELES_GESTION', items: [] })),
    gestiones: jest.fn(() => of({ items: [gestion], total: 1 })),
    gestion: jest.fn(() =>
      of({
        gestion,
        potencialidad: 'Alta',
        asignadaA: null,
        telefonos: ['600'],
        email: null,
        observaciones: [],
        documentos: [],
        gestionesAlcanzadas: [],
      }),
    ),
    cerrarGestion: jest.fn(() => of({ ...gestion, estado: 'CERRADA_POSITIVA' })),
    reabrirGestion: jest.fn(() => of(gestion)),
    observarGestion: jest.fn(),
    ...overrides,
  };
}

function store(visibilidades: Record<string, boolean>, nuuma: string | null = 'JZAHONE') {
  return {
    contexto: () => ({
      usuario: 'u',
      nombre: 'U',
      perfiles: [],
      perfilSgc30: 'ASESOR',
      estructura: nuuma ? { nuuma, oficina: '', delegacion: '', territorial: '' } : null,
      visibilidades,
    }),
    puede: (k: string) => visibilidades[k] === true,
  };
}

describe('GestionComercialClienteComponent', () => {
  const factory = createComponentFactory({
    component: GestionComercialClienteComponent,
    providers: [
      { provide: PGM_REPOSITORY, useValue: repo() },
      {
        provide: ContextoStore,
        useValue: store({
          gestionesSgc30: true,
          actividadComercial: true,
          anadirVencimiento: true,
        }),
      },
    ],
    detectChanges: false,
  });
  const crear = (
    r = repo(),
    s = store({ gestionesSgc30: true, actividadComercial: true, anadirVencimiento: true }),
  ) =>
    factory({
      props: { clienteId: 'C-1' },
      providers: [
        { provide: PGM_REPOSITORY, useValue: r },
        { provide: ContextoStore, useValue: s },
      ],
    });

  let spectator: Spectator<GestionComercialClienteComponent>;

  it('pinta los vencimientos con las columnas de PGM y los contadores', async () => {
    spectator = crear();
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    spectator.detectChanges();
    expect(spectator.query('.chips-estado')?.textContent).toContain('Todos 1');
    expect(spectator.query('.chips-estado')?.textContent).toContain('Completo 1');
    const texto = spectator.fixture.nativeElement.textContent as string;
    expect(texto).toContain('Entidad competencia');
    expect(texto).toContain('Clase de Vcto.');
    expect(texto).toContain('Allianz');
    expect(texto).not.toContain('+ Vencimiento');
  });

  it('muestra el bloqueo literal de Actividad comercial cuando el usuario no tiene NUUMA', async () => {
    spectator = crear(
      repo(),
      store({ gestionesSgc30: false, actividadComercial: false, anadirVencimiento: false }, null),
    );
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    spectator.component.seccion.set('actividad');
    spectator.detectChanges();
    const texto = spectator.fixture.nativeElement.textContent as string;
    expect(texto).toContain(TEXTOS_GC.accionNoDisponible('sin Nuuma'));
    expect(texto).toContain(TEXTOS_GC.puedesSgc20);
    spectator.component.seccion.set('gestiones');
    spectator.detectChanges();
    expect(spectator.fixture.nativeElement.textContent).toContain(TEXTOS_GC.sinPermisoGestiones);
    expect(spectator.fixture.nativeElement.textContent).not.toContain('+ Vencimiento');
  });

  it('abre el detalle de una gestión y permite cerrarla', async () => {
    const r = repo();
    spectator = crear(r);
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    jest.spyOn(window, 'confirm').mockReturnValue(true);
    spectator.component.seccion.set('gestiones');
    await spectator.component.abrirGestion(gestion as never);
    spectator.detectChanges();
    expect(spectator.fixture.nativeElement.textContent).toContain('Potencialidad de éxito');
    const detalle = spectator.component.detalleGestion();
    expect(detalle).not.toBeNull();
    if (detalle) {
      await spectator.component.cerrarGestion(detalle, 'POSITIVA');
    }
    expect(r.cerrarGestion).toHaveBeenCalledWith('G-1', 'POSITIVA');
  });

  it('mantiene el mensaje de error de PGM cuando falla el detalle de gestión', async () => {
    spectator = crear(repo({ gestion: jest.fn(() => throwError(() => new Error('403'))) }));
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    spectator.component.seccion.set('gestiones');
    await spectator.component.abrirGestion(gestion as never);
    spectator.detectChanges();
    expect(spectator.fixture.nativeElement.textContent).toContain(TEXTOS_GC.errorDetalleGestion);
  });
});
