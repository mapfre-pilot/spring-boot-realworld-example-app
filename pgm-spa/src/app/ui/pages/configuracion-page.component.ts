import { CommonModule } from '@angular/common';
import { Component, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import {
  Configuracion,
  ResultadoPrueba,
  Secreto,
  ServicioConfigurado,
} from '../../domain/models/api.models';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';

type Seccion =
  'origen' | 'gateway' | 'servicios' | 'appian' | 'entraid' | 'flags' | 'constantes' | 'usuarios';

export const TEXTOS_CONFIG = {
  titulo: 'Configuración',
  subtitulo:
    'Todo lo necesario para conectar PGM con los servicios reales. Los secretos se guardan cifrados en el BFF y nunca se muestran en claro.',
  secciones: {
    origen: 'Origen de datos',
    gateway: 'API Gateway',
    servicios: 'Servicios y credenciales',
    appian: 'Conexión con Appian',
    entraid: 'Entra ID',
    flags: 'Funcionalidades (constantes PGM)',
    constantes: 'URLs de lanzaderas',
    usuarios: 'Usuarios de prueba',
  } as Record<Seccion, string>,
  guardar: 'GUARDAR',
  restaurar: 'RESTAURAR POR DEFECTO',
  probar: 'Probar conexión',
  guardado: 'Configuración guardada',
  secretoGuardado: 'Secreto guardado (cifrado en el BFF)',
  secretoBorrado: 'Secreto borrado',
  sinInformar: 'Sin informar',
  informado: 'Informado',
};

const ETIQUETA_FLAG: Record<string, string> = {
  tarificacionSalud: 'Tarificación Salud (piloto)',
  gestionComercial: 'Gestión comercial',
  cuadroMando: 'Cuadro de Mando',
  clickToCall: 'Click2Call',
  visualizacionRecibos: 'Detalle de recibos (PGM_visualizacionRecibos)',
  detallePrestaciones: 'Detalle de prestaciones (PGM_CONS_VER_DETALLE_PRESTACIONES)',
  mostrarExclusivoCorredor: 'Mostrar exclusivo corredor (PGM_Mostrar_ExclusivoCorredor)',
  mostrarDpve: 'Mostrar DpV (PGM_mostrarDPVE)',
};

/** /configuracion — pestaña de administración (solo PGM_ADMINISTRADOR). */
@Component({
  selector: 'pgm-configuracion-page',
  standalone: true,
  imports: [CommonModule, FormsModule, EstadoComponent, IconoComponent],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    <section class="card">
      <div class="row">
        <h1>{{ t.titulo }}</h1>
        @if (cfg(); as c) {
          <span class="chip">Entorno {{ c.entorno }}</span>
        }
        <span class="spacer"></span>
        <button type="button" class="btn btn-secundario" (click)="restaurar()">
          {{ t.restaurar }}
        </button>
        <button
          type="button"
          class="btn"
          [disabled]="guardando()"
          (click)="guardar()"
          data-testid="guardar"
        >
          {{ t.guardar }}
        </button>
      </div>
      <p class="muted">{{ t.subtitulo }}</p>
      @if (mensaje(); as m) {
        <div
          class="alerta"
          [class.alerta-ok]="!esError()"
          [class.alerta-error]="esError()"
          data-testid="mensaje"
        >
          <pgm-icono nombre="aviso" [tam]="16" /> {{ m }}
        </div>
      }
      <div class="tabs">
        @for (s of secciones; track s) {
          <button type="button" [class.activa]="seccion() === s" (click)="seccion.set(s)">
            {{ t.secciones[s] }}
          </button>
        }
      </div>

      @if (cfg(); as c) {
        @switch (seccion()) {
          @case ('origen') {
            <p class="muted">
              Elige de dónde lee el BFF cada capacidad: <strong>API Canal</strong> (specs
              PROD-APICANAL-*) o los <strong>servicios legacy</strong> que usa hoy PGM en Appian.
              Ambos salen por el API Gateway; el cambio se aplica sin reiniciar.
            </p>
            <div class="grid grid-2">
              <label
                >Origen global
                <select [(ngModel)]="c.origenDatos.global" data-testid="origen-global">
                  <option value="API_CANAL">API Canal</option>
                  <option value="LEGACY">Legacy PGM (Appian)</option>
                </select></label
              >
              <label
                >Entorno de los servicios (URL por entorno)
                <select [(ngModel)]="c.origenDatos.entornoServicios">
                  <option value="DEV">DEV</option>
                  <option value="PRE">PRE (el que usa Appian TEST)</option>
                  <option value="PRO">PRO</option>
                </select></label
              >
            </div>
            <h3>Por capacidad</h3>
            <table class="tabla" data-testid="origen-capacidades">
              <thead>
                <tr>
                  <th>Capacidad</th>
                  <th>Origen</th>
                  <th>Servicio legacy de PGM</th>
                </tr>
              </thead>
              <tbody>
                @for (cap of capacidades; track cap.clave) {
                  <tr>
                    <td>{{ cap.nombre }}</td>
                    <td>
                      <select
                        [ngModel]="c.origenDatos.porCapacidad[cap.clave] ?? 'HEREDAR'"
                        (ngModelChange)="c.origenDatos.porCapacidad[cap.clave] = $event"
                      >
                        <option value="HEREDAR">Heredar global</option>
                        <option value="API_CANAL">API Canal</option>
                        <option value="LEGACY">Legacy PGM</option>
                      </select>
                    </td>
                    <td class="muted">{{ cap.legacy }}</td>
                  </tr>
                }
              </tbody>
            </table>
            <label class="inline flag">
              <input type="checkbox" [(ngModel)]="c.origenDatos.llamadaDirectaPruebas" />
              Llamada directa a los servicios (solo pruebas sin API Gateway): usa la «URL
              {{ c.origenDatos.entornoServicios }}» y las credenciales de cada servicio. En
              DEV/PRE/PRO debe estar desactivado.
            </label>
          }
          @case ('gateway') {
            <div class="grid grid-2">
              <label
                >URL base del Gateway <input [(ngModel)]="c.gateway.baseUrl" data-testid="gw-url"
              /></label>
              <label>Tenant <input [(ngModel)]="c.gateway.tenant" /></label>
              <label>Company ID <input [(ngModel)]="c.gateway.companyId" /></label>
              <label
                >Timeout conexión (ms)
                <input type="number" [(ngModel)]="c.gateway.connectTimeoutMs"
              /></label>
              <label
                >Timeout lectura (ms) <input type="number" [(ngModel)]="c.gateway.readTimeoutMs"
              /></label>
            </div>
            <h3>Rutas publicadas en el Gateway</h3>
            <table class="tabla" data-testid="rutas">
              <thead>
                <tr>
                  <th>Ruta lógica</th>
                  <th>Path</th>
                </tr>
              </thead>
              <tbody>
                @for (r of c.gateway.rutas | keyvalue; track r.key) {
                  <tr>
                    <td>
                      <code>{{ r.key }}</code>
                    </td>
                    <td>
                      <input
                        [ngModel]="r.value"
                        (ngModelChange)="c.gateway.rutas[r.key] = $event"
                      />
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          }
          @case ('servicios') {
            @for (s of c.servicios; track s.clave) {
              <details class="servicio" [attr.data-testid]="'servicio-' + s.clave">
                <summary>
                  <span class="chip" [class.chip-ok]="s.origen === 'API_CANAL'">{{
                    s.origen === 'API_CANAL' ? 'API Canal' : 'Legacy'
                  }}</span>
                  <strong>{{ s.nombre }}</strong>
                  <span class="muted">{{ s.autenticacion }}</span>
                  <span class="spacer"></span>
                  <span
                    class="chip"
                    [class.chip-ok]="credencialesCompletas(s)"
                    [class.chip-aviso]="!credencialesCompletas(s)"
                  >
                    {{ credencialesCompletas(s) ? 'Credenciales OK' : 'Faltan credenciales' }}
                  </span>
                  <label class="inline"
                    ><input type="checkbox" [(ngModel)]="s.habilitado" /> Habilitado</label
                  >
                </summary>
                <p class="muted">
                  {{ s.descripcion }} · ruta Gateway <code>{{ s.rutaGateway }}</code>
                </p>
                <div class="grid grid-3">
                  @for (u of s.urlPorEntorno | keyvalue; track u.key) {
                    <label
                      >URL {{ u.key }}
                      <input [ngModel]="u.value" (ngModelChange)="s.urlPorEntorno[u.key] = $event"
                    /></label>
                  }
                </div>
                <label
                  >Tipo de autenticación
                  <select [(ngModel)]="s.autenticacion">
                    <option value="NINGUNA">Ninguna</option>
                    <option value="API_KEY">API key</option>
                    <option value="OAUTH_CLIENT_CREDENTIALS">OAuth client credentials</option>
                    <option value="BASIC">Basic</option>
                    <option value="CABECERAS">Cabeceras (USER-ID / NUUMA)</option>
                    <option value="COOKIE">Cookie (Citrix)</option>
                  </select>
                </label>
                <h4>Credenciales</h4>
                @for (cr of s.credenciales; track cr.nombre) {
                  <div class="fila-secreto">
                    <span class="nombre"
                      >{{ cr.descripcion }} <code>{{ cr.nombre }}</code></span
                    >
                    <span
                      class="chip"
                      [class.chip-ok]="cr.informado"
                      [class.chip-aviso]="!cr.informado"
                    >
                      {{ cr.informado ? t.informado + ' ' + cr.enmascarado : t.sinInformar }}
                    </span>
                    <input
                      type="password"
                      autocomplete="new-password"
                      placeholder="Nuevo valor"
                      [(ngModel)]="nuevos[s.clave + '/' + cr.nombre]"
                    />
                    <button type="button" class="btn-enlace" (click)="guardarSecreto(s.clave, cr)">
                      Guardar
                    </button>
                    @if (cr.informado) {
                      <button type="button" class="btn-enlace" (click)="borrarSecreto(s.clave, cr)">
                        Borrar
                      </button>
                    }
                  </div>
                }
                <div class="row">
                  <button type="button" class="btn btn-secundario" (click)="probar(s)">
                    {{ t.probar }}
                  </button>
                  @if (pruebas()[s.clave]; as r) {
                    <span
                      class="chip"
                      [class.chip-ok]="r.ok"
                      [class.chip-error]="!r.ok"
                      [attr.data-testid]="'prueba-' + s.clave"
                    >
                      {{ r.ok ? 'OK' : 'KO' }} {{ r.httpStatus ?? '' }} · {{ r.latenciaMs }} ms ·
                      {{ r.mensaje }}
                    </span>
                  }
                </div>
              </details>
            }
          }
          @case ('appian') {
            <label class="inline"
              ><input type="checkbox" [(ngModel)]="c.appian.habilitado" /> Coexistencia con PGM en
              Appian habilitada</label
            >
            <div class="grid grid-2">
              <label>URL de Appian <input [(ngModel)]="c.appian.urlBase" /></label>
              <label>Site PGM <input [(ngModel)]="c.appian.sitePgm" /></label>
              <label>Site SGO <input [(ngModel)]="c.appian.siteSgo" /></label>
              <label>Usuario de servicio <input [(ngModel)]="c.appian.usuarioServicio" /></label>
            </div>
            <h3>Web APIs de Appian</h3>
            @for (w of c.appian.webApis | keyvalue; track w.key) {
              <label
                >{{ w.key }}
                <input [ngModel]="w.value" (ngModelChange)="c.appian.webApis[w.key] = $event"
              /></label>
            }
            <h4>API key</h4>
            <div class="fila-secreto">
              <span class="nombre">{{ c.appian.apiKey.descripcion }}</span>
              <span
                class="chip"
                [class.chip-ok]="c.appian.apiKey.informado"
                [class.chip-aviso]="!c.appian.apiKey.informado"
              >
                {{
                  c.appian.apiKey.informado
                    ? t.informado + ' ' + c.appian.apiKey.enmascarado
                    : t.sinInformar
                }}
              </span>
              <input
                type="password"
                autocomplete="new-password"
                placeholder="Nueva API key"
                [(ngModel)]="nuevos['appian/apiKey']"
              />
              <button
                type="button"
                class="btn-enlace"
                (click)="guardarSecreto('appian', c.appian.apiKey)"
              >
                Guardar
              </button>
            </div>
          }
          @case ('entraid') {
            <label class="inline"
              ><input type="checkbox" [(ngModel)]="c.entraId.habilitado" /> Autenticación Entra ID
              habilitada</label
            >
            <div class="grid grid-2">
              <label>Tenant ID <input [(ngModel)]="c.entraId.tenantId" /></label>
              <label>Client ID (App Registration) <input [(ngModel)]="c.entraId.clientId" /></label>
              <label>Scope <input [(ngModel)]="c.entraId.scope" /></label>
              <label>Issuer <input [(ngModel)]="c.entraId.issuer" /></label>
              <label>Audience <input [(ngModel)]="c.entraId.audience" /></label>
              <label
                >Redirect URIs (una por línea)
                <textarea
                  rows="4"
                  [ngModel]="c.entraId.redirectUris.join('\\n')"
                  (ngModelChange)="c.entraId.redirectUris = lineas($event)"
                ></textarea>
              </label>
            </div>
            <h4>Client secret del BFF</h4>
            <div class="fila-secreto">
              <span class="nombre">{{ c.entraId.clientSecretBff.descripcion }}</span>
              <span
                class="chip"
                [class.chip-ok]="c.entraId.clientSecretBff.informado"
                [class.chip-aviso]="!c.entraId.clientSecretBff.informado"
              >
                {{
                  c.entraId.clientSecretBff.informado
                    ? t.informado + ' ' + c.entraId.clientSecretBff.enmascarado
                    : t.sinInformar
                }}
              </span>
              <input
                type="password"
                autocomplete="new-password"
                placeholder="Nuevo client secret"
                [(ngModel)]="nuevos['entraid/clientSecret']"
              />
              <button
                type="button"
                class="btn-enlace"
                (click)="guardarSecreto('entraid', c.entraId.clientSecretBff)"
              >
                Guardar
              </button>
            </div>
            <p class="muted">
              La SPA pide el scope por PKCE; el BFF valida issuer, audience y scope. Las redirect
              URIs deben estar dadas de alta en la plataforma «Single-page application» del App
              Registration.
            </p>
          }
          @case ('flags') {
            @for (f of c.flags | keyvalue; track f.key) {
              <label class="inline flag">
                <input
                  type="checkbox"
                  [ngModel]="f.value"
                  (ngModelChange)="c.flags[f.key] = $event"
                />
                {{ etiquetaFlag(f.key) }} <code>{{ f.key }}</code>
              </label>
            }
          }
          @case ('constantes') {
            @for (k of c.constantes | keyvalue; track k.key) {
              <label
                ><code>{{ k.key }}</code>
                <input [ngModel]="k.value" (ngModelChange)="c.constantes[k.key] = $event"
              /></label>
            }
          }
          @case ('usuarios') {
            <table class="tabla">
              <thead>
                <tr>
                  <th>Usuario</th>
                  <th>Perfiles</th>
                  <th>NUUMA</th>
                  <th>Perfil SGC 3.0</th>
                  <th>Descripción</th>
                </tr>
              </thead>
              <tbody>
                @for (u of c.usuariosPrueba; track u.usuario) {
                  <tr>
                    <td>
                      <code>{{ u.usuario }}</code>
                    </td>
                    <td>{{ u.perfiles.join(', ') }}</td>
                    <td>{{ u.nuuma ?? '—' }}</td>
                    <td>{{ u.perfilSgc30 ?? '—' }}</td>
                    <td>{{ u.descripcion }}</td>
                  </tr>
                } @empty {
                  <tr>
                    <td colspan="5" class="muted">
                      En entornos corporativos los usuarios vienen de Entra ID e iMediador.
                    </td>
                  </tr>
                }
              </tbody>
            </table>
            <p class="muted">
              En perfil local se seleccionan con la cabecera <code>X-Usuario-Local</code> y los
              perfiles con <code>X-PGM-Perfiles</code>.
            </p>
          }
        }
        @if (c.ultimaModificacion) {
          <p class="muted">
            Última modificación {{ c.ultimaModificacion | date: 'dd/MM/yyyy HH:mm' }} por
            {{ c.modificadoPor }}
          </p>
        }
      }
    </section>
  `,
  styles: [
    `
      .tabs {
        display: flex;
        flex-wrap: wrap;
        gap: 0.25rem;
        border-bottom: 1px solid #ddd;
        margin: 1rem 0;
      }
      .tabs button {
        background: none;
        border: 0;
        border-bottom: 3px solid transparent;
        padding: 0.5rem 0.9rem;
        cursor: pointer;
        font: inherit;
      }
      .tabs button.activa {
        border-bottom-color: #c8102e;
        font-weight: 600;
      }
      label {
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
        font-size: 0.9rem;
        margin-bottom: 0.6rem;
      }
      label.inline {
        flex-direction: row;
        align-items: center;
        gap: 0.5rem;
      }
      input:not([type='checkbox']),
      select,
      textarea {
        padding: 0.4rem 0.5rem;
        border: 1px solid #bbb;
        border-radius: 3px;
        font: inherit;
      }
      .grid-3 {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 0.75rem;
      }
      .servicio {
        border: 1px solid #e3e3e3;
        border-radius: 6px;
        padding: 0.5rem 0.9rem;
        margin-bottom: 0.6rem;
      }
      .servicio summary {
        display: flex;
        gap: 0.6rem;
        align-items: center;
        cursor: pointer;
        list-style: none;
      }
      .servicio summary::-webkit-details-marker {
        display: none;
      }
      .fila-secreto {
        display: grid;
        grid-template-columns: 1fr auto 16rem auto auto;
        gap: 0.6rem;
        align-items: center;
        padding: 0.35rem 0;
        border-bottom: 1px solid #f0f0f0;
      }
      .fila-secreto .nombre code {
        color: #777;
        margin-left: 0.3rem;
      }
      .tabla {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.9rem;
      }
      .tabla th,
      .tabla td {
        text-align: left;
        padding: 0.4rem 0.6rem;
        border-bottom: 1px solid #eee;
      }
      .tabla input {
        width: 100%;
      }
      h3,
      h4 {
        color: #c8102e;
        font-size: 0.95rem;
        margin: 0.9rem 0 0.4rem;
      }
      .alerta {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        padding: 0.6rem 0.8rem;
        border-radius: 4px;
        margin: 0.75rem 0;
      }
      .alerta-ok {
        background: #e9f7ef;
        color: #1e7b45;
      }
      .alerta-error {
        background: #fdecec;
        color: #a4121c;
      }
      .flag {
        padding: 0.3rem 0;
      }
    `,
  ],
})
export class ConfiguracionPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly t = TEXTOS_CONFIG;
  readonly secciones: Seccion[] = [
    'origen',
    'gateway',
    'servicios',
    'appian',
    'entraid',
    'flags',
    'constantes',
    'usuarios',
  ];
  readonly seccion = signal<Seccion>('origen');
  readonly capacidades = [
    {
      clave: 'clientes',
      nombre: 'Clientes (búsqueda y ficha)',
      legacy: 'Clients EDGE · clients/search y client/{id}',
    },
    {
      clave: 'polizas',
      nombre: 'Pólizas',
      legacy: 'Clients EDGE MRCBack · client/{id}/policies; Denodo productsDetail',
    },
    {
      clave: 'recibos',
      nombre: 'Recibos',
      legacy: 'Client API · client/{id}/receipts; Denodo receiptsDetail; GESYC',
    },
    {
      clave: 'siniestros',
      nombre: 'Prestaciones / siniestros',
      legacy: 'negocioclientes · client/{id}/claims; METS',
    },
    {
      clave: 'ventas',
      nombre: 'Ventas (tarificación Salud, presupuestos)',
      legacy: 'Health API · individual/simulation; negocioclientes projects',
    },
  ];
  readonly cfg = signal<Configuracion | null>(null);
  readonly pruebas = signal<Record<string, ResultadoPrueba>>({});
  readonly cargando = signal(false);
  readonly guardando = signal(false);
  readonly error = signal<string | null>(null);
  readonly mensaje = signal<string | null>(null);
  readonly esError = signal(false);
  readonly serviciosSinCredenciales = computed(
    () =>
      this.cfg()?.servicios.filter((s) => s.habilitado && !this.credencialesCompletas(s)).length ??
      0,
  );
  nuevos: Record<string, string> = {};

  constructor() {
    void this.cargar();
  }

  async cargar(): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    try {
      this.cfg.set(await firstValueFrom(this.repo.configuracion()));
    } catch (e) {
      this.error.set(this.detalle(e));
    } finally {
      this.cargando.set(false);
    }
  }

  credencialesCompletas(s: ServicioConfigurado): boolean {
    return s.autenticacion === 'NINGUNA' || s.credenciales.every((c) => c.informado);
  }

  etiquetaFlag(k: string): string {
    return ETIQUETA_FLAG[k] ?? k;
  }

  lineas(texto: string): string[] {
    return texto
      .split('\n')
      .map((l) => l.trim())
      .filter((l) => l.length > 0);
  }

  async guardar(): Promise<void> {
    const c = this.cfg();
    if (!c) return;
    this.guardando.set(true);
    try {
      this.cfg.set(await firstValueFrom(this.repo.guardarConfiguracion(c)));
      this.informar(this.t.guardado, false);
    } catch (e) {
      this.informar(this.detalle(e), true);
    } finally {
      this.guardando.set(false);
    }
  }

  async restaurar(): Promise<void> {
    try {
      this.cfg.set(await firstValueFrom(this.repo.restaurarConfiguracion()));
      this.informar('Configuración restaurada a los valores por defecto', false);
    } catch (e) {
      this.informar(this.detalle(e), true);
    }
  }

  async guardarSecreto(ambito: string, s: Secreto): Promise<void> {
    const clave = `${ambito}/${s.nombre}`;
    const valor = this.nuevos[clave];
    if (!valor) {
      this.informar('Introduce el valor del secreto antes de guardar', true);
      return;
    }
    try {
      this.cfg.set(await firstValueFrom(this.repo.guardarSecreto(ambito, s.nombre, valor)));
      this.nuevos[clave] = '';
      this.informar(this.t.secretoGuardado, false);
    } catch (e) {
      this.informar(this.detalle(e), true);
    }
  }

  async borrarSecreto(ambito: string, s: Secreto): Promise<void> {
    try {
      this.cfg.set(await firstValueFrom(this.repo.borrarSecreto(ambito, s.nombre)));
      this.informar(this.t.secretoBorrado, false);
    } catch (e) {
      this.informar(this.detalle(e), true);
    }
  }

  async probar(s: ServicioConfigurado): Promise<void> {
    try {
      const r = await firstValueFrom(this.repo.probarServicio(s.clave));
      this.pruebas.update((p) => ({ ...p, [s.clave]: r }));
    } catch (e) {
      this.informar(this.detalle(e), true);
    }
  }

  private informar(texto: string, error: boolean): void {
    this.mensaje.set(texto);
    this.esError.set(error);
  }

  private detalle(e: unknown): string {
    const err = e as { error?: { detail?: string }; message?: string };
    return err?.error?.detail ?? err?.message ?? 'No se ha podido completar la operación';
  }
}
