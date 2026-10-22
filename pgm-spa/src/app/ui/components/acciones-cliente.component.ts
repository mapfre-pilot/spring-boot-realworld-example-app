import { CommonModule } from '@angular/common';
import { Component, computed, inject, input, output, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import {
  Cliente,
  ClienteTotal,
  Comunicaciones,
  DocumentoCliente,
  EmpresaVinculada,
  FirmaRgpd,
  MasDatos,
  PeriodoComunicaciones,
  PlanPagos,
  ResultadoAccion,
  SimulacionPlanPagos,
} from '../../domain/models/api.models';
import { IconoComponent } from './icono.component';

/** Textos literales del menú ACCIONES y de las palancas observados en PGM (Appian TEST, área A). */
export const TEXTOS_ACCIONES = {
  menu: 'ACCIONES',
  masDatos: 'Más datos cliente',
  centroComunicaciones: 'Centro de comunicaciones',
  cdd: 'Consulta y descarga de documentación',
  sgc20: 'Acceso a SGC 2.0',
  sva: 'Servicios de valor añadido',
  inducir: 'Inducir',
  digitalizarDni: 'Digitalizar DNI',
  firmarRgpd: 'Firmar RGPD',
  altaAci: 'Solicitar Alta en ACI',
  simularPlan: 'Simular',
  altaClienteTotal: 'Alta Cliente Total',
  altaClub: 'Alta en ClubMAPFRE',
  sinDocumentos: 'No hay documentos para los criterios seleccionados',
  sinComunicaciones: 'No hay comunicaciones en el periodo seleccionado',
  entendido: 'ENTENDIDO',
  cancelar: 'CANCELAR',
  guardar: 'GUARDAR',
  firmar: 'FIRMAR',
  solicitar: 'SOLICITAR',
  anadirEmpresa: 'AÑADIR EMPRESA',
};
export const PESTANAS_MAS_DATOS = [
  'Más datos',
  'Datos de contacto',
  'Origen de los datos',
] as const;
export const PESTANAS_COMUNICACIONES = ['Alertas', 'Interacciones', 'Reclamaciones'] as const;

type Dialogo =
  | null
  | 'mas-datos'
  | 'comunicaciones'
  | 'cdd'
  | 'dni'
  | 'rgpd'
  | 'aci'
  | 'plan-pagos'
  | 'cliente-total'
  | 'inducir';

@Component({
  selector: 'pgm-acciones-cliente',
  standalone: true,
  imports: [CommonModule, FormsModule, IconoComponent],
  template: `
    <details
      class="acciones-menu"
      [open]="menuAbierto()"
      (toggle)="menuAbierto.set($any($event.target).open)"
    >
      <summary class="btn btn-secundario" data-testid="menu-acciones">
        {{ t.menu }} <pgm-icono nombre="buscar" [tam]="14" />
      </summary>
      <div class="menu" role="menu">
        <button type="button" role="menuitem" (click)="abrir('mas-datos')">{{ t.masDatos }}</button>
        <button type="button" role="menuitem" (click)="abrir('comunicaciones')">
          {{ t.centroComunicaciones }}
        </button>
        <button type="button" role="menuitem" (click)="abrir('cdd')">{{ t.cdd }}</button>
        @if (nuuma()) {
          <a role="menuitem" [href]="urlSgc20" target="_blank" rel="noopener">{{ t.sgc20 }}</a>
          <a role="menuitem" [href]="urlSva" target="_blank" rel="noopener">{{ t.sva }}</a>
          <button type="button" role="menuitem" (click)="abrir('inducir')">{{ t.inducir }}</button>
        }
      </div>
    </details>

    <!-- Acciones de las palancas (solo las que aplican al estado del cliente) -->
    <div class="palancas-acciones">
      @if (!cliente().palancas.dniDigitalizado) {
        <button type="button" class="enlace" (click)="abrir('dni')">{{ t.digitalizarDni }}</button>
      }
      @if (!cliente().palancas.rgpdFirmado) {
        <button type="button" class="enlace" (click)="abrir('rgpd')">{{ t.firmarRgpd }}</button>
      }
      @if (!cliente().palancas.altaAci) {
        <button type="button" class="enlace" (click)="abrir('aci')">{{ t.altaAci }}</button>
      }
      @if (!cliente().palancas.planPagos) {
        <button type="button" class="enlace" (click)="abrir('plan-pagos')">
          Plan de pagos · {{ t.simularPlan }}
        </button>
      }
      @if (!cliente().palancas.clienteTotal) {
        <button type="button" class="enlace" (click)="abrir('cliente-total')">
          {{ t.altaClienteTotal }}
        </button>
      }
    </div>

    @if (dialogo(); as d) {
      <div class="backdrop" role="presentation">
        <div class="dialogo" role="dialog" aria-modal="true">
          @if (mensaje(); as m) {
            <div
              class="alerta"
              [class.alerta-error]="error()"
              [class.alerta-ok]="!error()"
              data-testid="mensaje"
            >
              <pgm-icono nombre="aviso" [tam]="16" /> {{ m }}
            </div>
          }

          @switch (d) {
            @case ('mas-datos') {
              <h2>{{ t.masDatos }}</h2>
              <div class="tabs">
                @for (p of pestanasMasDatos; track p) {
                  <button type="button" [class.activa]="pestana() === p" (click)="pestana.set(p)">
                    {{ p }}
                  </button>
                }
              </div>
              @if (masDatos(); as md) {
                @switch (pestana()) {
                  @case ('Más datos') {
                    <dl class="datos">
                      <dt>Nacionalidad</dt>
                      <dd>{{ md.nacionalidad || '–' }}</dd>
                      <dt>Idioma</dt>
                      <dd>{{ md.idioma || '–' }}</dd>
                      <dt>Fecha de nacimiento</dt>
                      <dd>
                        {{ md.fechaNacimiento ? (md.fechaNacimiento | date: 'dd/MM/yyyy') : '–' }}
                      </dd>
                      <dt>Edad</dt>
                      <dd>{{ md.edad ?? '–' }}</dd>
                      <dt>Sexo</dt>
                      <dd>{{ md.sexo || '–' }}</dd>
                      <dt>Nº hijos</dt>
                      <dd>{{ md.numeroHijos ?? '–' }}</dd>
                      <dt>Tipo de persona</dt>
                      <dd>{{ md.tipoPersona || '–' }}</dd>
                      <dt>Estado civil</dt>
                      <dd>{{ md.estadoCivil || '–' }}</dd>
                      <dt>Empleado MAPFRE</dt>
                      <dd>{{ md.empleadoMapfre ? 'Sí' : 'No' }}</dd>
                      <dt>Profesión</dt>
                      <dd>{{ md.profesion || '–' }}</dd>
                    </dl>
                  }
                  @case ('Datos de contacto') {
                    <table class="tabla">
                      <thead>
                        <tr>
                          <th>Tipo</th>
                          <th>Motivo</th>
                          <th>Prefijo</th>
                          <th>Número</th>
                        </tr>
                      </thead>
                      <tbody>
                        @for (tel of md.telefonos; track $index) {
                          <tr>
                            <td>{{ tel.tipo }}</td>
                            <td>{{ tel.motivo }}</td>
                            <td>{{ tel.prefijo }}</td>
                            <td>{{ tel.numero }}</td>
                          </tr>
                        }
                      </tbody>
                    </table>
                    <p><strong>Emails:</strong> {{ md.emails.join(', ') || '–' }}</p>
                    <div class="form-fila">
                      <label
                        >Nuevo móvil <input [(ngModel)]="nuevoTelefono" placeholder="600000000"
                      /></label>
                      <label
                        >Nuevo email
                        <input [(ngModel)]="nuevoEmail" placeholder="correo@dominio.es"
                      /></label>
                      <button type="button" class="btn" (click)="guardarContacto()">
                        {{ t.guardar }}
                      </button>
                    </div>
                  }
                  @case ('Origen de los datos') {
                    <dl class="datos">
                      @for (o of md.origenDatos | keyvalue; track o.key) {
                        <dt>{{ o.key }}</dt>
                        <dd>{{ o.value }}</dd>
                      }
                    </dl>
                  }
                }
                @for (a of md.avisos; track a) {
                  <div class="alerta alerta-info">
                    <pgm-icono nombre="aviso" [tam]="16" /> {{ a }}
                  </div>
                }
              }
            }
            @case ('comunicaciones') {
              <h2>{{ t.centroComunicaciones }}</h2>
              <div class="tabs" role="tablist" data-testid="pestanas-comunicaciones">
                @for (p of pestanasComunicaciones; track p) {
                  <button
                    type="button"
                    role="tab"
                    [class.activa]="pestanaComunicacion() === p"
                    (click)="pestanaComunicacion.set(p)"
                  >
                    {{
                      p === 'Alertas'
                        ? 'Alertas (' + (comunicaciones()?.alertas?.length ?? 0) + ')'
                        : p === 'Interacciones'
                          ? 'Interacciones (' + (comunicaciones()?.interacciones?.length ?? 0) + ')'
                          : 'Reclamaciones (' + (comunicaciones()?.reclamaciones?.length ?? 0) + ')'
                    }}
                  </button>
                }
              </div>
              <label
                >Periodo
                <select [ngModel]="periodo()" (ngModelChange)="cambiarPeriodo($event)">
                  @for (p of periodos; track p.valor) {
                    <option [value]="p.valor">{{ p.texto }}</option>
                  }
                </select>
              </label>
              @if (comunicaciones(); as cm) {
                @switch (pestanaComunicacion()) {
                  @case ('Alertas') {
                    @if (!cm.alertas.length) {
                      <p class="muted">{{ t.sinComunicaciones }}</p>
                    }
                    @for (a of cm.alertas; track $index) {
                      <div class="fila">
                        <strong>{{ a.tipo }}</strong> · {{ a.texto }}
                        <span class="muted">{{ a.fecha | date: 'dd/MM/yyyy' }}</span>
                      </div>
                    }
                  }
                  @case ('Interacciones') {
                    @if (!cm.interacciones.length) {
                      <p class="muted">{{ t.sinComunicaciones }}</p>
                    }
                    <table class="tabla">
                      <thead>
                        <tr>
                          <th>Fecha</th>
                          <th>Canal</th>
                          <th>Motivo</th>
                          <th>Descripción</th>
                          <th>Estado</th>
                        </tr>
                      </thead>
                      <tbody>
                        @for (i of cm.interacciones; track i.id) {
                          <tr>
                            <td>{{ i.fecha | date: 'dd/MM/yyyy HH:mm' }}</td>
                            <td>{{ i.canal }}</td>
                            <td>{{ i.motivo }}</td>
                            <td>{{ i.descripcion }}</td>
                            <td>{{ i.estado }}</td>
                          </tr>
                        }
                      </tbody>
                    </table>
                  }
                  @case ('Reclamaciones') {
                    @if (!cm.reclamaciones.length) {
                      <p class="muted">{{ t.sinComunicaciones }}</p>
                    }
                    <table class="tabla">
                      <thead>
                        <tr>
                          <th>Fecha</th>
                          <th>Canal</th>
                          <th>Motivo</th>
                          <th>Descripción</th>
                          <th>Estado</th>
                        </tr>
                      </thead>
                      <tbody>
                        @for (i of cm.reclamaciones; track i.id) {
                          <tr>
                            <td>{{ i.fecha | date: 'dd/MM/yyyy' }}</td>
                            <td>{{ i.canal }}</td>
                            <td>{{ i.motivo }}</td>
                            <td>{{ i.descripcion }}</td>
                            <td>{{ i.estado }}</td>
                          </tr>
                        }
                      </tbody>
                    </table>
                  }
                }
              }
            }
            @case ('cdd') {
              <h2>{{ t.cdd }}</h2>
              <div class="form-fila">
                <label
                  >Tipo de documento
                  <select [(ngModel)]="tipoDocumento" (ngModelChange)="cargarDocumentos()">
                    <option value="">Todos</option>
                    <option value="DNI">DNI</option>
                    <option value="RGPD">RGPD</option>
                    <option value="CONTRATO">Contrato</option>
                  </select>
                </label>
              </div>
              @if (documentos(); as docs) {
                @if (!docs.length) {
                  <p class="muted">{{ t.sinDocumentos }}</p>
                } @else {
                  <table class="tabla" data-testid="tabla-cdd">
                    <thead>
                      <tr>
                        <th>Tipo</th>
                        <th>Nombre</th>
                        <th>Fecha alta</th>
                        <th>Vigencia</th>
                        <th>Nivel LOPD</th>
                        <th>Clasificación</th>
                        <th>Contrato</th>
                        <th></th>
                      </tr>
                    </thead>
                    <tbody>
                      @for (dc of docs; track dc.id) {
                        <tr>
                          <td>{{ dc.tipoDocumento }}</td>
                          <td>{{ dc.nombre }}</td>
                          <td>{{ dc.fechaAlta | date: 'dd/MM/yyyy' }}</td>
                          <td>
                            {{ dc.fechaVigencia ? (dc.fechaVigencia | date: 'dd/MM/yyyy') : '–' }}
                          </td>
                          <td>{{ dc.nivelLopd }}</td>
                          <td>{{ dc.clasificacion }}</td>
                          <td>{{ dc.contrato || '–' }}</td>
                          <td>
                            <button type="button" class="enlace" (click)="descargar(dc)">
                              Descargar
                            </button>
                          </td>
                        </tr>
                      }
                    </tbody>
                  </table>
                }
              }
            }
            @case ('dni') {
              <h2>{{ t.digitalizarDni }}</h2>
              <p>
                Se iniciará la captura de la documentación identificativa del cliente (componente
                Captura DNI).
              </p>
              <label
                >Canal
                <select [(ngModel)]="canalDni">
                  <option value="CAPTURA_WEB">Captura web</option>
                  <option value="TABLETA">Tableta</option>
                </select>
              </label>
              <div class="botones">
                <button type="button" class="btn btn-secundario" (click)="cerrar()">
                  {{ t.cancelar }}
                </button>
                <button type="button" class="btn" [disabled]="cargando()" (click)="solicitarDni()">
                  {{ t.solicitar }}
                </button>
              </div>
            }
            @case ('rgpd') {
              <h2>{{ t.firmarRgpd }}</h2>
              @if (firma(); as f) {
                <p>Seleccione el método de firma de la cláusula RGPD:</p>
                @for (m of f.metodos; track m.codigo) {
                  <label class="radio" [class.deshabilitado]="!m.disponible">
                    <input
                      type="radio"
                      name="metodo"
                      [value]="m.codigo"
                      [disabled]="!m.disponible"
                      [(ngModel)]="metodoFirma"
                    />
                    {{ m.nombre }}
                    @if (!m.disponible) {
                      <span class="muted"
                        >(requiere {{ m.codigo === 'SMS' ? 'teléfono móvil' : 'email' }})</span
                      >
                    }
                  </label>
                }
                <div class="botones">
                  <button type="button" class="btn btn-secundario" (click)="cerrar()">
                    {{ t.cancelar }}
                  </button>
                  <button
                    type="button"
                    class="btn"
                    [disabled]="!metodoFirma || cargando()"
                    (click)="firmarRgpd()"
                  >
                    {{ t.firmar }}
                  </button>
                </div>
              }
            }
            @case ('aci') {
              <h2>{{ t.altaAci }}</h2>
              <p>
                Se enviará al cliente un enlace de activación del Área de Cliente (ACI) por móvil o
                email.
              </p>
              <div class="botones">
                <button type="button" class="btn btn-secundario" (click)="cerrar()">
                  {{ t.cancelar }}
                </button>
                <button type="button" class="btn" [disabled]="cargando()" (click)="altaAci()">
                  {{ t.solicitar }}
                </button>
              </div>
            }
            @case ('plan-pagos') {
              <h2>Plan de pagos</h2>
              @if (planPagos(); as pp) {
                @if (!pp.susceptible) {
                  <div class="alerta alerta-info">
                    <pgm-icono nombre="aviso" [tam]="16" /> {{ pp.mensaje }}
                  </div>
                } @else {
                  <div class="botones">
                    <button
                      type="button"
                      class="btn"
                      [disabled]="!pp.individualDisponible || cargando()"
                      (click)="simular('INDIVIDUAL')"
                    >
                      Simular individual
                    </button>
                    <button
                      type="button"
                      class="btn"
                      [disabled]="!pp.familiarDisponible || cargando()"
                      (click)="simular('FAMILIAR')"
                    >
                      Simular familiar
                    </button>
                  </div>
                }
              }
              @if (simulacion(); as s) {
                <dl class="datos" data-testid="simulacion">
                  <dt>Tipo</dt>
                  <dd>{{ s.tipo }}</dd>
                  <dt>Cuota mensual</dt>
                  <dd>{{ s.cuotaMensual | currency: 'EUR' }}</dd>
                  <dt>Nº cuotas</dt>
                  <dd>{{ s.numeroCuotas }}</dd>
                  <dt>Productos</dt>
                  <dd>{{ s.productosIncluidos.join(', ') }}</dd>
                </dl>
              }
            }
            @case ('cliente-total') {
              <h2>{{ t.altaClienteTotal }}</h2>
              @if (clienteTotal(); as ct) {
                <dl class="datos">
                  <dt>NIF</dt>
                  <dd>{{ ct.nif }}</dd>
                  <dt>Nombre</dt>
                  <dd>{{ ct.nombre }}</dd>
                  <dt>Clasificación actual</dt>
                  <dd>{{ ct.clasificacionActual }}</dd>
                  <dt>Nueva clasificación</dt>
                  <dd>{{ ct.nuevaClasificacion || '–' }}</dd>
                </dl>
                <h3>Empresas vinculadas ({{ ct.empresas.length }})</h3>
                <table class="tabla">
                  <thead>
                    <tr>
                      <th>CIF</th>
                      <th>Razón social</th>
                      <th>Cargo</th>
                      <th>Estado</th>
                    </tr>
                  </thead>
                  <tbody>
                    @for (e of ct.empresas; track e.cif) {
                      <tr>
                        <td>{{ e.cif }}</td>
                        <td>{{ e.razonSocial }}</td>
                        <td>{{ e.cargo || '–' }}</td>
                        <td>{{ e.estado }}</td>
                      </tr>
                    }
                  </tbody>
                </table>
                <div class="form-fila">
                  <label
                    >CIF <input [(ngModel)]="nuevaEmpresa.cif" placeholder="B12345678"
                  /></label>
                  <label>Razón social <input [(ngModel)]="nuevaEmpresa.razonSocial" /></label>
                  <label>Cargo <input [(ngModel)]="nuevaEmpresa.cargo" /></label>
                  <button
                    type="button"
                    class="btn"
                    [disabled]="cargando()"
                    (click)="anadirEmpresa()"
                  >
                    {{ t.anadirEmpresa }}
                  </button>
                </div>
              }
            }
            @case ('inducir') {
              <h2>{{ t.inducir }}</h2>
              <p>
                Inducción del cliente a los canales digitales (requiere teléfono o email y cliente
                no Robinson).
              </p>
              <label
                >Canal
                <select [(ngModel)]="canalInduccion">
                  <option value="WEB">Web</option>
                  <option value="APP">App</option>
                  <option value="EMAIL">Email</option>
                  <option value="SMS">SMS</option>
                </select>
              </label>
              <div class="botones">
                <button type="button" class="btn btn-secundario" (click)="cerrar()">
                  {{ t.cancelar }}
                </button>
                <button type="button" class="btn" [disabled]="cargando()" (click)="inducir()">
                  {{ t.inducir | uppercase }}
                </button>
              </div>
            }
          }

          @if (d === 'mas-datos' || d === 'comunicaciones' || d === 'cdd') {
            <div class="botones">
              <button type="button" class="btn" (click)="cerrar()">{{ t.entendido }}</button>
            </div>
          }
        </div>
      </div>
    }
  `,
  styles: [
    `
      :host {
        display: contents;
      }
      .acciones-menu {
        position: relative;
      }
      .acciones-menu summary {
        list-style: none;
        cursor: pointer;
        display: inline-flex;
        gap: 0.35rem;
        align-items: center;
      }
      .acciones-menu summary::-webkit-details-marker {
        display: none;
      }
      .menu {
        position: absolute;
        right: 0;
        z-index: 20;
        min-width: 16rem;
        background: #fff;
        border: 1px solid #d9d9d9;
        border-radius: 4px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        display: flex;
        flex-direction: column;
      }
      .menu button,
      .menu a {
        text-align: left;
        padding: 0.6rem 1rem;
        background: none;
        border: 0;
        color: #222;
        text-decoration: none;
        cursor: pointer;
        font: inherit;
      }
      .menu button:hover,
      .menu a:hover {
        background: #f5f5f5;
      }
      .palancas-acciones {
        display: flex;
        flex-wrap: wrap;
        gap: 0.25rem 1rem;
      }
      .enlace {
        background: none;
        border: 0;
        color: #c8102e;
        cursor: pointer;
        padding: 0;
        font: inherit;
        text-decoration: underline;
      }
      .backdrop {
        position: fixed;
        inset: 0;
        background: rgba(0, 0, 0, 0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 100;
      }
      .dialogo {
        background: #fff;
        border-radius: 6px;
        width: min(56rem, 94vw);
        max-height: 90vh;
        overflow: auto;
        padding: 1.25rem 1.5rem;
      }
      .dialogo h2 {
        margin: 0 0 1rem;
        font-size: 1.15rem;
        color: #222;
        border-bottom: 2px solid #c8102e;
        padding-bottom: 0.5rem;
      }
      .tabs {
        display: flex;
        gap: 0.25rem;
        border-bottom: 1px solid #ddd;
        margin-bottom: 1rem;
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
      .datos {
        display: grid;
        grid-template-columns: max-content 1fr;
        gap: 0.35rem 1.25rem;
      }
      .datos dt {
        color: #666;
      }
      .datos dd {
        margin: 0;
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
      .tabla th {
        background: #f7f7f7;
        font-weight: 600;
      }
      .form-fila {
        display: flex;
        flex-wrap: wrap;
        gap: 1rem;
        align-items: end;
        margin-top: 1rem;
      }
      .form-fila label,
      .dialogo > label {
        display: flex;
        flex-direction: column;
        gap: 0.25rem;
        font-size: 0.9rem;
      }
      input,
      select {
        padding: 0.4rem 0.5rem;
        border: 1px solid #bbb;
        border-radius: 3px;
        font: inherit;
      }
      .radio {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        padding: 0.35rem 0;
      }
      .radio.deshabilitado {
        color: #999;
      }
      .botones {
        display: flex;
        justify-content: flex-end;
        gap: 0.75rem;
        margin-top: 1.25rem;
      }
      .btn {
        background: #c8102e;
        color: #fff;
        border: 0;
        border-radius: 3px;
        padding: 0.55rem 1.1rem;
        font: inherit;
        font-weight: 600;
        cursor: pointer;
      }
      .btn[disabled] {
        opacity: 0.5;
        cursor: default;
      }
      .btn-secundario {
        background: #fff;
        color: #c8102e;
        border: 1px solid #c8102e;
      }
      .alerta {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        padding: 0.6rem 0.8rem;
        border-radius: 4px;
        margin-bottom: 1rem;
      }
      .alerta-info {
        background: #eef5fb;
        color: #1d4e89;
      }
      .alerta-ok {
        background: #e9f7ef;
        color: #1e7b45;
      }
      .alerta-error {
        background: #fdecec;
        color: #a4121c;
      }
      .muted {
        color: #777;
      }
      .fila {
        padding: 0.35rem 0;
        border-bottom: 1px solid #eee;
      }
    `,
  ],
})
export class AccionesClienteComponent {
  readonly t = TEXTOS_ACCIONES;
  readonly cliente = input.required<Cliente>();
  readonly cambio = output<void>();

  private readonly repo = inject(PGM_REPOSITORY);
  private readonly contexto = inject(ContextoStore);

  readonly nuuma = computed(() => this.contexto.nuuma());
  readonly urlSgc20 = 'https://sgc20.mapfre.net/';
  readonly urlSva = 'https://sva.mapfre.net/';

  readonly menuAbierto = signal(false);
  readonly dialogo = signal<Dialogo>(null);
  readonly cargando = signal(false);
  readonly mensaje = signal<string | null>(null);
  readonly error = signal(false);

  readonly pestanasMasDatos = PESTANAS_MAS_DATOS;
  readonly pestana = signal<(typeof this.pestanasMasDatos)[number]>('Más datos');
  readonly masDatos = signal<MasDatos | null>(null);
  nuevoTelefono = '';
  nuevoEmail = '';

  readonly periodos: { valor: PeriodoComunicaciones; texto: string }[] = [
    { valor: '30D', texto: 'Últimos 30 días' },
    { valor: '12M', texto: 'Últimos 12 meses' },
    { valor: '3A', texto: 'Últimos 3 años' },
  ];
  readonly periodo = signal<PeriodoComunicaciones>('30D');
  readonly comunicaciones = signal<Comunicaciones | null>(null);
  readonly pestanasComunicaciones = PESTANAS_COMUNICACIONES;
  readonly pestanaComunicacion = signal<(typeof this.pestanasComunicaciones)[number]>('Alertas');

  tipoDocumento = '';
  readonly documentos = signal<DocumentoCliente[] | null>(null);

  canalDni = 'CAPTURA_WEB';
  readonly firma = signal<FirmaRgpd | null>(null);
  metodoFirma = '';
  readonly planPagos = signal<PlanPagos | null>(null);
  readonly simulacion = signal<SimulacionPlanPagos | null>(null);
  readonly clienteTotal = signal<ClienteTotal | null>(null);
  nuevaEmpresa: EmpresaVinculada = this.empresaVacia();
  canalInduccion = 'WEB';

  async abrir(d: Exclude<Dialogo, null>): Promise<void> {
    this.menuAbierto.set(false);
    this.mensaje.set(null);
    this.error.set(false);
    this.simulacion.set(null);
    this.dialogo.set(d);
    const id = this.cliente().id;
    await this.ejecutar(async () => {
      switch (d) {
        case 'mas-datos':
          this.pestana.set('Más datos');
          this.masDatos.set(await firstValueFrom(this.repo.masDatos(id)));
          break;
        case 'comunicaciones':
          this.comunicaciones.set(
            await firstValueFrom(this.repo.comunicaciones(id, this.periodo())),
          );
          break;
        case 'cdd':
          await this.cargarDocumentos();
          break;
        case 'rgpd':
          this.metodoFirma = '';
          this.firma.set(await firstValueFrom(this.repo.metodosFirmaRgpd(id)));
          break;
        case 'plan-pagos':
          this.planPagos.set(await firstValueFrom(this.repo.planPagos(id)));
          break;
        case 'cliente-total':
          this.nuevaEmpresa = this.empresaVacia();
          this.clienteTotal.set(await firstValueFrom(this.repo.clienteTotal(id)));
          break;
        default:
          break;
      }
    });
  }

  cerrar(): void {
    this.dialogo.set(null);
  }

  async cambiarPeriodo(p: PeriodoComunicaciones): Promise<void> {
    this.periodo.set(p);
    await this.ejecutar(async () =>
      this.comunicaciones.set(await firstValueFrom(this.repo.comunicaciones(this.cliente().id, p))),
    );
  }

  async cargarDocumentos(): Promise<void> {
    const lista = await firstValueFrom(
      this.repo.documentosCliente(this.cliente().id, this.tipoDocumento || undefined),
    );
    this.documentos.set(lista.items);
  }

  descargar(d: DocumentoCliente): void {
    this.mensaje.set(`Descarga solicitada: ${d.nombre}`);
    this.error.set(false);
  }

  async guardarContacto(): Promise<void> {
    const actual = this.masDatos();
    if (!actual) return;
    const telefonos = [...actual.telefonos];
    if (this.nuevoTelefono) {
      telefonos.push({
        tipo: 'MOVIL',
        motivo: 'PERSONAL',
        prefijo: '+34',
        numero: this.nuevoTelefono,
      });
    }
    const emails = this.nuevoEmail ? [...actual.emails, this.nuevoEmail] : [...actual.emails];
    await this.ejecutar(async () => {
      this.masDatos.set(
        await firstValueFrom(
          this.repo.actualizarContacto(this.cliente().id, { telefonos, emails }),
        ),
      );
      this.nuevoTelefono = '';
      this.nuevoEmail = '';
      this.informar('Datos de contacto actualizados', true);
    });
  }

  async solicitarDni(): Promise<void> {
    await this.accion(() => this.repo.solicitarDigitalizacionDni(this.cliente().id, this.canalDni));
  }

  async firmarRgpd(): Promise<void> {
    await this.accion(() => this.repo.firmarRgpd(this.cliente().id, this.metodoFirma));
  }

  async altaAci(): Promise<void> {
    await this.accion(() => this.repo.solicitarAltaAci(this.cliente().id));
  }

  async simular(tipo: 'INDIVIDUAL' | 'FAMILIAR'): Promise<void> {
    await this.ejecutar(async () =>
      this.simulacion.set(
        await firstValueFrom(this.repo.simularPlanPagos(this.cliente().id, tipo)),
      ),
    );
  }

  async anadirEmpresa(): Promise<void> {
    await this.ejecutar(async () => {
      this.clienteTotal.set(
        await firstValueFrom(
          this.repo.anadirEmpresaVinculada(this.cliente().id, this.nuevaEmpresa),
        ),
      );
      this.nuevaEmpresa = this.empresaVacia();
      this.informar('Empresa vinculada añadida (pendiente de firma)', true);
    });
  }

  async inducir(): Promise<void> {
    await this.accion(() => this.repo.inducir(this.cliente().id, this.canalInduccion));
  }

  private async accion(f: () => import('rxjs').Observable<ResultadoAccion>): Promise<void> {
    await this.ejecutar(async () => {
      const r = await firstValueFrom(f());
      this.informar(`${r.mensaje} (ref. ${r.referencia})`, true);
      this.cambio.emit();
    });
  }

  private async ejecutar(f: () => Promise<void>): Promise<void> {
    this.cargando.set(true);
    try {
      await f();
    } catch (e: unknown) {
      const detalle = (e as { error?: { detail?: string }; message?: string })?.error?.detail;
      this.informar(detalle ?? 'No se ha podido completar la acción', false);
    } finally {
      this.cargando.set(false);
    }
  }

  private informar(texto: string, ok: boolean): void {
    this.mensaje.set(texto);
    this.error.set(!ok);
  }

  private empresaVacia(): EmpresaVinculada {
    return {
      cif: '',
      razonSocial: '',
      actividad: null,
      segmento: null,
      clasificacion: null,
      cargo: null,
      estado: null,
    };
  }
}
