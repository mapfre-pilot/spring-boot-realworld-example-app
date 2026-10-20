import { Spectator, createComponentFactory } from '@ngneat/spectator/jest';
import { of, throwError } from 'rxjs';
import { PGM_REPOSITORY, PgmRepository } from '../../application/ports/pgm.repository';
import { Configuracion } from '../../domain/models/api.models';
import { ConfiguracionPageComponent, TEXTOS_CONFIG } from './configuracion-page.component';

function config(): Configuracion {
  return {
    entorno: 'LOCAL',
    gateway: {
      baseUrl: 'https://gw',
      tenant: 'MAPFRE_ES',
      companyId: '81',
      connectTimeoutMs: 2000,
      readTimeoutMs: 5000,
      rutas: { pgo: '/legacy/pgo' },
    },
    servicios: [
      {
        clave: 'pgo',
        nombre: 'PGO',
        descripcion: 'd',
        rutaGateway: 'pgo',
        origen: 'LEGACY',
        autenticacion: 'API_KEY',
        urlPorEntorno: { PRE: 'https://apipgo.pre' },
        cabeceras: {},
        habilitado: true,
        credenciales: [
          {
            nombre: 'apiKey',
            descripcion: 'x-api-key',
            informado: false,
            enmascarado: null,
            origen: null,
          },
        ],
      },
    ],
    appian: {
      urlBase: 'https://a',
      sitePgm: '/suite/sites/pgm-mapfre',
      siteSgo: '/suite/sites/sgo',
      usuarioServicio: 'svc',
      webApis: {},
      apiKey: {
        nombre: 'apiKey',
        descripcion: 'k',
        informado: false,
        enmascarado: null,
        origen: null,
      },
      habilitado: false,
    },
    entraId: {
      habilitado: false,
      tenantId: 't',
      clientId: 'c',
      scope: 's',
      issuer: 'i',
      audience: 'a',
      redirectUris: ['http://localhost:4200'],
      clientSecretBff: {
        nombre: 'clientSecret',
        descripcion: 'cs',
        informado: false,
        enmascarado: null,
        origen: null,
      },
    },
    flags: { clickToCall: true },
    constantes: { PGM_URL_APPS: 'https://apps.pre.mapfre.net' },
    usuariosPrueba: [],
    ultimaModificacion: null,
    modificadoPor: null,
  };
}

function repo(sobre: Partial<PgmRepository> = {}): PgmRepository {
  const c = config();
  return {
    configuracion: () => of(c),
    guardarConfiguracion: () =>
      of({ ...c, modificadoPor: 'admin', ultimaModificacion: '2026-10-20T10:00:00Z' }),
    guardarSecreto: () =>
      of({
        ...c,
        servicios: [
          {
            ...c.servicios[0],
            credenciales: [
              { ...c.servicios[0].credenciales[0], informado: true, enmascarado: '••••••ABCD' },
            ],
          },
        ],
      }),
    probarServicio: () =>
      of({
        servicio: 'pgo',
        ok: true,
        httpStatus: 200,
        latenciaMs: 12,
        url: 'https://gw/legacy/pgo/health',
        mensaje: 'Perfil local',
      }),
    ...sobre,
  } as unknown as PgmRepository;
}

describe('ConfiguracionPageComponent', () => {
  const factory = createComponentFactory({
    component: ConfiguracionPageComponent,
    providers: [{ provide: PGM_REPOSITORY, useValue: repo() }],
    detectChanges: false,
  });
  const crear = (r = repo()) => factory({ providers: [{ provide: PGM_REPOSITORY, useValue: r }] });
  let spectator: Spectator<ConfiguracionPageComponent>;

  it('carga la configuración y muestra las 7 secciones y las rutas del Gateway', async () => {
    spectator = crear();
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    spectator.detectChanges();
    const texto = spectator.fixture.nativeElement.textContent as string;
    for (const s of Object.values(TEXTOS_CONFIG.secciones)) expect(texto).toContain(s);
    expect(spectator.query('[data-testid=rutas]')?.textContent).toContain('pgo');
  });

  it('guarda un secreto y lo muestra enmascarado, nunca en claro', async () => {
    spectator = crear();
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    spectator.component.seccion.set('servicios');
    spectator.component.nuevos['pgo/apiKey'] = 'clave-secreta-ABCD';
    const servicio = spectator.component.cfg()?.servicios[0];
    expect(servicio).toBeDefined();
    if (servicio) await spectator.component.guardarSecreto('pgo', servicio.credenciales[0]);
    spectator.detectChanges();
    const texto = spectator.fixture.nativeElement.textContent as string;
    expect(texto).toContain('••••••ABCD');
    expect(texto).not.toContain('clave-secreta-ABCD');
    expect(spectator.component.nuevos['pgo/apiKey']).toBe('');
  });

  it('prueba la conexión de un servicio y muestra el error literal del BFF al guardar', async () => {
    spectator = crear(
      repo({
        guardarConfiguracion: () =>
          throwError(() => ({
            status: 400,
            error: { detail: 'URL base del API Gateway no válida' },
          })),
      }),
    );
    spectator.detectChanges();
    await spectator.fixture.whenStable();
    spectator.component.seccion.set('servicios');
    const servicio = spectator.component.cfg()?.servicios[0];
    expect(servicio).toBeDefined();
    if (servicio) await spectator.component.probar(servicio);
    spectator.detectChanges();
    expect(spectator.query('[data-testid=prueba-pgo]')?.textContent).toContain('OK 200');
    await spectator.component.guardar();
    spectator.detectChanges();
    expect(spectator.query('[data-testid=mensaje]')?.textContent).toContain(
      'URL base del API Gateway no válida',
    );
  });
});
