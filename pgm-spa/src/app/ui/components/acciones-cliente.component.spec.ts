import { Spectator, createComponentFactory } from '@ngneat/spectator/jest';
import { of, throwError } from 'rxjs';
import { PGM_REPOSITORY, PgmRepository } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Cliente } from '../../domain/models/api.models';
import { AccionesClienteComponent, TEXTOS_ACCIONES } from './acciones-cliente.component';

function cliente(
  parcial: Partial<Cliente['palancas']> = {},
  extra: Partial<Cliente> = {},
): Cliente {
  return {
    id: 'C-1',
    nombre: 'Laura',
    apellidos: 'Demo',
    tipoDocumento: 'NIF',
    documento: '00000001R',
    fechaNacimiento: '1980-01-01',
    nacionalidad: 'ES',
    tipologia: 'PARTICULAR',
    estado: 'EN_VIGOR',
    vip: false,
    robinson: false,
    exclusivoCorredor: false,
    direccion: { via: '', localidad: '', provincia: '', codigoPostal: '' },
    telefono: '600000001',
    email: 'laura@example.invalid',
    oficinaGestora: '',
    gestorAsignado: '',
    palancas: {
      dniDigitalizado: true,
      rgpdFirmado: true,
      altaAci: true,
      clienteTotal: true,
      planPagos: true,
      enFamilia: true,
      dpv: false,
      ...parcial,
    },
    alertas: [],
    familia: [],
    posicionBancaria: '',
    descuentoVinculacion: 0,
    ...extra,
  } as Cliente;
}

function repo(sobrescribir: Partial<PgmRepository> = {}): PgmRepository {
  return {
    documentosCliente: () =>
      of({
        total: 1,
        items: [
          {
            id: 'D-1',
            tipoDocumento: 'RGPD',
            codificacion: 'CLAUSULA',
            nombre: 'Cláusula RGPD firmada',
            fechaAlta: '2024-01-15',
            fechaVigencia: null,
            nivelLopd: 'Alto',
            clasificacion: 'Consentimiento',
            contrato: null,
            clausula: 'RGPD-2024',
          },
        ],
      }),
    metodosFirmaRgpd: () =>
      of({
        estado: 'PENDIENTE',
        metodos: [
          { codigo: 'BIOMETRICA', nombre: 'Firma biométrica', disponible: true },
          { codigo: 'EMAIL', nombre: 'Email', disponible: false },
        ],
      }),
    firmarRgpd: () =>
      of({ estado: 'ENVIADA', mensaje: 'Solicitud enviada por BIOMETRICA', referencia: 'RGPD-1' }),
    solicitarAltaAci: () =>
      throwError(() => ({
        status: 400,
        error: {
          detail:
            'Para solicitar el alta en ACI el cliente debe tener informado un teléfono móvil o un email',
        },
      })),
    ...sobrescribir,
  } as unknown as PgmRepository;
}

function store(nuuma: string | null): Partial<ContextoStore> {
  return { nuuma: (() => nuuma) as unknown as ContextoStore['nuuma'] };
}

describe('AccionesClienteComponent', () => {
  const factory = createComponentFactory({
    component: AccionesClienteComponent,
    providers: [
      { provide: PGM_REPOSITORY, useValue: repo() },
      { provide: ContextoStore, useValue: store(null) },
    ],
    detectChanges: false,
  });
  const crear = (c: Cliente, r = repo(), nuuma: string | null = null) =>
    factory({
      props: { cliente: c },
      providers: [
        { provide: PGM_REPOSITORY, useValue: r },
        { provide: ContextoStore, useValue: store(nuuma) },
      ],
    });
  let spectator: Spectator<AccionesClienteComponent>;

  it('muestra el menú ACCIONES con las 3 entradas de PGM y oculta las de perfil comercial sin NUUMA', () => {
    spectator = crear(cliente());
    spectator.detectChanges();
    const texto = spectator.fixture.nativeElement.textContent as string;
    expect(texto).toContain(TEXTOS_ACCIONES.masDatos);
    expect(texto).toContain(TEXTOS_ACCIONES.centroComunicaciones);
    expect(texto).toContain(TEXTOS_ACCIONES.cdd);
    expect(texto).not.toContain(TEXTOS_ACCIONES.inducir);
    expect(texto).not.toContain(TEXTOS_ACCIONES.digitalizarDni);
  });

  it('con NUUMA añade SGC 2.0, SVA e Inducir', () => {
    spectator = crear(cliente(), repo(), 'JZAHONE');
    spectator.detectChanges();
    const texto = spectator.fixture.nativeElement.textContent as string;
    expect(texto).toContain(TEXTOS_ACCIONES.sgc20);
    expect(texto).toContain(TEXTOS_ACCIONES.sva);
    expect(texto).toContain(TEXTOS_ACCIONES.inducir);
  });

  it('ofrece las acciones de palanca según el estado y firma RGPD con el método disponible', async () => {
    spectator = crear(cliente({ dniDigitalizado: false, rgpdFirmado: false, altaAci: false }));
    spectator.detectChanges();
    const texto = spectator.fixture.nativeElement.textContent as string;
    expect(texto).toContain(TEXTOS_ACCIONES.digitalizarDni);
    expect(texto).toContain(TEXTOS_ACCIONES.firmarRgpd);
    expect(texto).toContain(TEXTOS_ACCIONES.altaAci);
    await spectator.component.abrir('rgpd');
    spectator.detectChanges();
    expect(spectator.component.firma()?.metodos.find((m) => m.codigo === 'EMAIL')?.disponible).toBe(
      false,
    );
    spectator.component.metodoFirma = 'BIOMETRICA';
    await spectator.component.firmarRgpd();
    spectator.detectChanges();
    expect(spectator.query('[data-testid=mensaje]')?.textContent).toContain(
      'Solicitud enviada por BIOMETRICA',
    );
    expect(spectator.component.error()).toBe(false);
  });

  it('muestra el detail RFC 9457 literal cuando el BFF rechaza el alta en ACI', async () => {
    spectator = crear(cliente({ altaAci: false }));
    spectator.detectChanges();
    await spectator.component.abrir('aci');
    await spectator.component.altaAci();
    spectator.detectChanges();
    expect(spectator.component.error()).toBe(true);
    expect(spectator.query('[data-testid=mensaje]')?.textContent).toContain(
      'debe tener informado un teléfono móvil o un email',
    );
  });

  it('CDD lista los documentos del cliente', async () => {
    spectator = crear(cliente());
    spectator.detectChanges();
    await spectator.component.abrir('cdd');
    spectator.detectChanges();
    expect(spectator.query('[data-testid=tabla-cdd]')?.textContent).toContain(
      'Cláusula RGPD firmada',
    );
  });
});
