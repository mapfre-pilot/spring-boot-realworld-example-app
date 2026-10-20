import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, computed, effect, inject, input, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import {
  Cliente,
  GestionComercial,
  Lanzadera,
  Oportunidad,
  Poliza,
  Prestacion,
  Presupuesto,
  RAMOS,
  Ramo,
  Recibo,
  SolicitudSgo,
  TarificacionResultado,
  Visibilidad,
} from '../../domain/models/api.models';
import {
  CarruselRamosComponent,
  ContadorRamo,
  ETIQUETA_RAMO,
  ICONO_RAMO,
} from '../components/carrusel-ramos.component';
import { DialogoPasosComponent } from '../components/dialogo-pasos.component';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';
import { IndicadoresClienteComponent } from '../components/indicadores-cliente.component';
import { AccionesClienteComponent } from '../components/acciones-cliente.component';
import { GestionComercialClienteComponent } from '../components/gestion-comercial-cliente.component';
import {
  Columna,
  TablaExportableComponent,
  exportarCsv,
} from '../components/tabla-exportable.component';

type Principal = 'posicion' | 'comercial' | 'presupuestos';
type Pestana = 'productos' | 'prestaciones' | 'recibos' | 'sgo';

const badgeEstado = (v: unknown): string =>
  'badge' +
  (['ANULADA', 'ANULADO', 'RECHAZADA', 'DEVUELTO'].includes(`${v}`)
    ? ' rojo'
    : ['PENDIENTE', 'EN_TRAMITE', 'ABIERTA', 'SUSPENDIDA'].includes(`${v}`)
      ? ' naranja'
      : ['CERRADA'].includes(`${v}`)
        ? ' gris'
        : '');
const textoEstado = (v: unknown): string => `${v ?? ''}`.replace(/_/g, ' ');

/** /clientes/:id — ficha 360 del cliente: cabecera, palancas, resumen por ramo, posición, gestión comercial y presupuestos. */
@Component({
  selector: 'pgm-ficha-cliente-page',
  imports: [
    DatePipe,
    CurrencyPipe,
    FormsModule,
    RouterLink,
    IndicadoresClienteComponent,
    AccionesClienteComponent,
    TablaExportableComponent,
    EstadoComponent,
    DialogoPasosComponent,
    CarruselRamosComponent,
    IconoComponent,
    GestionComercialClienteComponent,
  ],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    @if (cliente(); as c) {
      @if (!c.palancas.rgpdFirmado) {
        <div class="alerta aviso-rgpd">
          <pgm-icono nombre="aviso" [tam]="26" />
          <span>
            Puedes utilizar los datos del Cliente/Potencial MAPFRE para la
            <strong>gestión de sus contratos o para resolver cualquier petición</strong> que
            solicite.
            <strong
              >Recaba su consentimiento para poder realizarle futuras gestiones comerciales</strong
            >
            (RGPD no firmado).
          </span>
        </div>
      }

      <section class="ficha">
        <div class="cabecera-cliente">
          <h1>
            {{ c.nombre }} {{ c.apellidos }} <span class="doc">({{ c.documento }})</span>
          </h1>
          <pgm-indicadores-cliente [c]="c" />
          <pgm-acciones-cliente [cliente]="c" (cambio)="cargar(c.id)" />
          <span class="sep"></span>
          <button
            class="contacto"
            type="button"
            (click)="llamar(c)"
            title="Llamar desde el centro de comunicaciones"
          >
            <pgm-icono nombre="telefono" /> {{ c.telefono || '–' }}
          </button>
          <span class="sep"></span>
          <span class="contacto"><pgm-icono nombre="email" /> {{ c.email || '–' }}</span>
          <span class="spacer"></span>
          <button
            class="btn-icono"
            type="button"
            [attr.aria-label]="'Alertas (' + c.alertas.length + ')'"
            (click)="verAlertas.set(!verAlertas())"
          >
            <pgm-icono nombre="campana" [tam]="22" />
            @if (c.alertas.length) {
              <span class="punto">{{ c.alertas.length }}</span>
            }
          </button>
          <button class="btn-icono" type="button" aria-label="Recargar" (click)="cargar(c.id)">
            <pgm-icono nombre="refrescar" [tam]="20" />
          </button>
        </div>

        @if (verAlertas()) {
          <div class="alertas">
            @for (a of c.alertas; track $index) {
              <div class="alerta">
                <pgm-icono nombre="aviso" />
                <span
                  ><strong>{{ a.tipo }}</strong> · {{ a.texto }}</span
                >
                <span class="spacer"></span>
                <span class="muted">{{ a.fecha | date: 'dd/MM/yyyy' }}</span>
              </div>
            } @empty {
              <div class="alerta alerta-info"><pgm-icono nombre="info" /> Sin alertas</div>
            }
          </div>
        }
        @if (llamadaId()) {
          <div class="alerta alerta-info">
            <pgm-icono nombre="telefono" /> Llamada registrada en el centro de comunicaciones:
            {{ llamadaId() }}
          </div>
        }

        <div class="datos-cliente">
          <div>
            <span class="etiqueta">Edad</span><strong>{{ edad() ?? '–' }} años</strong>
          </div>
          <div>
            <span class="etiqueta">Nacimiento</span
            ><strong>{{ c.fechaNacimiento | date: 'dd/MM/yyyy' }} · {{ c.nacionalidad }}</strong>
          </div>
          <div class="ancho">
            <span class="etiqueta">Dirección habitual</span>
            <strong class="mayus"
              >{{ c.direccion.via }} {{ c.direccion.numero }}, {{ c.direccion.codigoPostal }},
              {{ c.direccion.localidad }}, {{ c.direccion.provincia }}</strong
            >
          </div>
          <div>
            <span class="etiqueta">Oficina gestora</span><strong>{{ c.oficinaGestora }}</strong>
          </div>
          <div>
            <span class="etiqueta">Gestor</span><strong>{{ c.gestorAsignado }}</strong>
          </div>
        </div>

        <div class="franja">
          <pgm-indicadores-cliente [c]="c" vista="palancas" />
          <div class="cifras">
            <div class="cifra-bloque">
              <span class="cifra">{{ c.descuentoVinculacion ?? 0 }}%</span>
              <span class="rojo">Descuento vinculación</span>
            </div>
            <div class="cifra-bloque">
              <span class="cifra">{{ totalPrima() | currency: 'EUR' }}</span>
              <span>Total prima (tomador/titular)</span>
              <small class="muted">*No contabiliza productos anulados</small>
            </div>
            <div>
              <span class="chip-titulo">Familia</span>
              @for (m of c.familia; track m.clienteId) {
                <a [routerLink]="['/clientes', m.clienteId]" class="familiar"
                  >{{ m.nombre }} <span class="muted">({{ m.parentesco }})</span></a
                >
              } @empty {
                <span class="muted">Sin unidad familiar</span>
              }
            </div>
            <div>
              <span class="chip-titulo">Posición bancaria</span>
              <span>{{ c.posicionBancaria ?? 'Sin posición bancaria' }}</span>
            </div>
          </div>
        </div>
      </section>

      <section class="card">
        <h2>Resumen</h2>
        <pgm-carrusel-ramos
          [contadores]="contadores()"
          accionTexto="Vto. / Ppto."
          (seleccion)="filtrarRamo($event)"
          (accion)="abrirDialogo($event)"
        />
        <div class="row leyenda">
          <span class="spacer"></span><span class="punto-gris"></span> Tomador, titular o cotitular
        </div>
      </section>

      <div class="tabs principales">
        <button [class.activa]="principal() === 'posicion'" (click)="principal.set('posicion')">
          Posición del cliente
        </button>
        <button [class.activa]="principal() === 'comercial'" (click)="principal.set('comercial')">
          Gestión comercial
        </button>
        <button
          [class.activa]="principal() === 'presupuestos'"
          (click)="principal.set('presupuestos')"
        >
          Presupuestos
        </button>
      </div>

      <section class="card">
        @switch (principal()) {
          @case ('posicion') {
            <div class="row cabecera-posicion">
              <div class="subtabs">
                <button
                  [class.activa]="pestana() === 'productos'"
                  (click)="pestana.set('productos')"
                >
                  Productos
                </button>
                <button
                  [class.activa]="pestana() === 'prestaciones'"
                  (click)="pestana.set('prestaciones')"
                >
                  Prestaciones ({{ prestaciones().length }})
                </button>
                <button [class.activa]="pestana() === 'recibos'" (click)="pestana.set('recibos')">
                  Recibos ({{ recibos().length }})
                </button>
                <button [class.activa]="pestana() === 'sgo'" (click)="pestana.set('sgo')">
                  SGO ({{ sgo().length }})
                </button>
              </div>
              @if (pestana() === 'productos') {
                <select
                  aria-label="Estado de los productos"
                  [ngModel]="filtroEstado()"
                  (ngModelChange)="filtroEstado.set($event)"
                >
                  <option value="EN_VIGOR">En vigor ({{ cuentaEstado('EN_VIGOR') }})</option>
                  <option value="ANULADA">Anulados ({{ cuentaEstado('ANULADA') }})</option>
                  <option value="">Todos ({{ polizas().length }})</option>
                </select>
                @if (filtroRamo(); as r) {
                  <button class="chip" type="button" (click)="filtroRamo.set(null)">
                    {{ ramo(r) }} <pgm-icono nombre="cerrar" [tam]="13" />
                  </button>
                }
                <span class="spacer"></span>
                <button
                  class="btn-enlace"
                  [disabled]="!polizasFiltradas().length"
                  (click)="exportarProductos()"
                >
                  Descargar <pgm-icono nombre="descargar" [tam]="17" />
                </button>
              }
            </div>
            @switch (pestana()) {
              @case ('productos') {
                <table class="tabla productos">
                  <thead>
                    <tr>
                      <th></th>
                      <th>Ramo / Producto / Póliza</th>
                      <th>Riesgo</th>
                      <th>Importe</th>
                      <th>Fecha</th>
                      <th>Estado</th>
                      <th></th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    @for (p of polizasFiltradas(); track p.numero) {
                      <tr class="poliza">
                        <td class="icono-ramo">
                          <pgm-icono [nombre]="iconoRamo(p.ramo)" [tam]="24" [trazo]="1.5" />
                        </td>
                        <td>
                          <div class="ramo-txt">{{ ramo(p.ramo) }}</div>
                          <div>{{ p.producto }}</div>
                          <a [routerLink]="['/polizas', p.numero]">{{ p.numero }}</a>
                        </td>
                        <td class="muted">{{ p.riesgo }}</td>
                        <td>
                          <strong>{{ p.primaAnual | currency: 'EUR' }}</strong>
                          <div class="muted">{{ p.formaPago }}</div>
                        </td>
                        <td class="fechas">
                          <span class="muted">Efecto</span> {{ p.fechaEfecto | date: 'dd/MM/yyyy' }}
                          <br /><span class="muted">Vencimiento</span>
                          {{ p.fechaVencimiento | date: 'dd/MM/yyyy' }}
                        </td>
                        <td>
                          <span [class]="badge(p.estado)">{{ texto(p.estado) }}</span>
                        </td>
                        <td class="acciones">
                          <details>
                            <summary>Acciones</summary>
                            <div class="menu">
                              @for (a of p.acciones; track a) {
                                @if (lanzaderaDe(p); as l) {
                                  <a
                                    [href]="l.url"
                                    target="_blank"
                                    rel="noopener"
                                    (click)="auditar('accion:' + a)"
                                    >{{ a }} <small class="muted">({{ l.destino }})</small></a
                                  >
                                } @else {
                                  <span class="muted">{{ a }}</span>
                                }
                              }
                              @if (lanzaderaDe(p); as l) {
                                <a
                                  [href]="l.url"
                                  target="_blank"
                                  rel="noopener"
                                  (click)="auditar('lanzadera:' + l.codigo)"
                                  ><pgm-icono nombre="externo" [tam]="14" /> Abrir en
                                  {{ l.destino }}</a
                                >
                              }
                            </div>
                          </details>
                        </td>
                        <td>
                          <a
                            [routerLink]="['/polizas', p.numero]"
                            aria-label="Ver póliza"
                            class="flecha"
                            ><pgm-icono nombre="derecha" [trazo]="2.4"
                          /></a>
                        </td>
                      </tr>
                    } @empty {
                      <tr>
                        <td colspan="8" class="vacio">Sin productos para el filtro seleccionado</td>
                      </tr>
                    }
                  </tbody>
                </table>
              }
              @case ('recibos') {
                <pgm-tabla-exportable
                  titulo="Recibos"
                  nombreFichero="recibos"
                  [columnas]="colRecibos"
                  [filas]="recibos()"
                  [navegable]="true"
                  (filaSeleccionada)="irRecibo($event)"
                />
              }
              @case ('prestaciones') {
                <pgm-tabla-exportable
                  titulo="Prestaciones / siniestros"
                  nombreFichero="prestaciones"
                  [columnas]="colPrestaciones"
                  [filas]="prestaciones()"
                />
              }
              @case ('sgo') {
                <pgm-tabla-exportable
                  titulo="Solicitudes SGO"
                  nombreFichero="sgo"
                  [columnas]="colSgo"
                  [filas]="sgo()"
                />
              }
            }
          }
          @case ('comercial') {
            <pgm-gestion-comercial-cliente
              [clienteId]="id()"
              [cliente]="
                cliente()
                  ? { rgpd: !!cliente()!.palancas.rgpdFirmado, documento: cliente()!.documento }
                  : null
              "
            />
          }
          @case ('presupuestos') {
            @if (presupuestos().length === 0 && !hayFiltroPresupuestos()) {
              <div class="alerta alerta-info">
                <pgm-icono nombre="info" /> El cliente no tiene presupuestos
              </div>
            } @else {
              <form class="filtros-ppto" (ngSubmit)="(0)">
                <strong>Filtro de presupuestos</strong>
                <label
                  >Ramo
                  <select [(ngModel)]="filtroPpto.ramo" name="pRamo">
                    <option value="">Todos</option>
                    @for (r of ramosPpto(); track r) {
                      <option [value]="r">{{ ramo(r) }}</option>
                    }
                  </select></label
                >
                <label
                  >Nº de Presupuesto <input [(ngModel)]="filtroPpto.numero" name="pNumero"
                /></label>
                <button
                  type="button"
                  class="btn-secundario"
                  (click)="filtroPpto = { ramo: '', numero: '' }"
                >
                  Limpiar filtros
                </button>
                <button type="button" class="btn" (click)="cargar(id())">Actualizar</button>
              </form>
              <pgm-tabla-exportable
                titulo="Presupuestos"
                nombreFichero="presupuestos"
                [columnas]="colPresupuestos"
                [filas]="presupuestosFiltrados()"
                mensajeVacio="No hay resultados para los filtros seleccionados"
                [navegable]="true"
                (filaSeleccionada)="consultarPresupuesto($event)"
              />
              <small class="muted"
                >Consultar/Retomar: abre el presupuesto en el tarificador de su ramo (RM para
                Vida-Riesgo).</small
              >
            }
          }
        }
      </section>

      @if (bloqueoVto()) {
        <div
          class="backdrop"
          role="presentation"
          (click)="bloqueoVto.set(false)"
          (keydown.escape)="bloqueoVto.set(false)"
          tabindex="-1"
        >
          <div
            class="dialogo bloqueo-vto"
            role="dialog"
            aria-modal="true"
            aria-labelledby="titulo-bloqueo"
            (click)="$event.stopPropagation()"
            (keydown)="$event.stopPropagation()"
            tabindex="0"
          >
            <h2 id="titulo-bloqueo">Añadir Vencimiento / Presupuesto</h2>
            <div class="tabs">
              <button class="activa">Vencimientos</button><button disabled>Presupuestos</button>
            </div>
            <div class="alerta alerta-info">
              <pgm-icono nombre="info" />
              <div>
                <p>
                  <strong
                    >Esta acción aún no está disponible en PGM para tu usuario ({{
                      store.contexto()?.estructura?.nuuma ?? store.contexto()?.usuario
                    }})</strong
                  >
                </p>
                <p>
                  Contacta con el administrador de la aplicación si consideras que debes acceder
                </p>
              </div>
            </div>
            <div class="row" style="justify-content:flex-end">
              <button class="btn" (click)="bloqueoVto.set(false)">ENTENDIDO</button>
            </div>
          </div>
        </div>
      }

      <pgm-dialogo-pasos
        [abierto]="dialogo()"
        titulo="Nuevo vencimiento / presupuesto"
        [pasos]="['Producto', 'Datos', 'Resultado']"
        [puedeAvanzar]="puedeAvanzar()"
        textoFinal="Guardar borrador"
        (cerrar)="dialogo.set(false)"
        (cambioPaso)="pasoDialogo.set($event)"
        (finalizar)="guardarBorrador()"
      >
        @switch (pasoDialogo()) {
          @case (0) {
            <label
              >Ramo / producto
              <select [(ngModel)]="formulario.producto">
                <option value="">Selecciona…</option>
                @if (store.puede(V.TARIFICACION_SALUD)) {
                  <option value="SALUD-FAMILIAR">Salud · MAPFRE Salud Familiar</option>
                  <option value="SALUD-ELITE">Salud · MAPFRE Salud Élite</option>
                }
                <option value="AUTOS-TR">Autos · Todo Riesgo (lanzadera NSE)</option>
                <option value="HOGAR-PLUS">Hogar · Hogar Plus (lanzadera NSE)</option>
              </select>
            </label>
          }
          @case (1) {
            @if (esSalud()) {
              <div class="grid grid-3">
                <label
                  >Código postal <input [(ngModel)]="formulario.codigoPostal" maxlength="5"
                /></label>
                <label
                  >Edades de asegurados (coma)
                  <input [(ngModel)]="edadesTexto" placeholder="38, 36, 7"
                /></label>
                <label
                  >Copago
                  <select [(ngModel)]="formulario.copago">
                    <option [ngValue]="false">Sin copago</option>
                    <option [ngValue]="true">Con copago</option>
                  </select></label
                >
              </div>
              <p>
                <button class="btn btn-secundario" type="button" (click)="tarificar()">
                  Tarificar
                </button>
              </p>
            } @else {
              <p class="alerta">
                <pgm-icono nombre="info" />
                Este producto se tarifica en la lanzadera corporativa del ramo (NSE). Se registrará
                únicamente la oportunidad.
              </p>
            }
          }
          @case (2) {
            @if (tarifa(); as t) {
              <dl class="datos">
                <dt>Producto</dt>
                <dd>{{ t.producto }}</dd>
                <dt>Tarificación</dt>
                <dd>{{ t.id }} · {{ t.estado }}</dd>
                <dt>Prima mensual</dt>
                <dd>
                  <strong>{{ t.primaMensual | currency: 'EUR' }}</strong>
                </dd>
                <dt>Prima anual</dt>
                <dd>{{ t.primaAnual | currency: 'EUR' }}</dd>
                <dt>Coberturas</dt>
                <dd>{{ t.coberturas.join(', ') }}</dd>
              </dl>
            } @else {
              <p class="muted">
                Sin tarificación: se guardará el borrador con los datos introducidos.
              </p>
            }
            @if (borradorId()) {
              <p class="alerta alerta-info">Borrador guardado: {{ borradorId() }}</p>
            }
          }
        }
        @if (errorDialogo()) {
          <div class="alerta alerta-error">{{ errorDialogo() }}</div>
        }
      </pgm-dialogo-pasos>
    }
  `,
  styles: `
    .aviso-rgpd {
      font-size: 1rem;
    }
    .ficha {
      background: #fff;
      box-shadow: var(--pgm-sombra);
    }
    .cabecera-cliente {
      display: flex;
      align-items: center;
      flex-wrap: wrap;
      gap: 0.9rem;
      padding: 1.25rem 1.5rem 0.5rem;
    }
    .cabecera-cliente h1 {
      margin: 0;
      font-size: 1.35rem;
      color: #3c4650;
    }
    .doc {
      font-weight: 400;
    }
    .sep {
      width: 1px;
      height: 22px;
      background: var(--pgm-borde-input);
    }
    .contacto {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      font: inherit;
      font-weight: 600;
      background: none;
      border: none;
      padding: 0;
      color: var(--pgm-texto);
    }
    .contacto pgm-icono {
      color: var(--pgm-rojo);
    }
    button.contacto {
      cursor: pointer;
    }
    .punto {
      position: absolute;
      top: 2px;
      right: 2px;
      min-width: 16px;
      height: 16px;
      border-radius: 8px;
      background: var(--pgm-rojo);
      color: #fff;
      font-size: 0.68rem;
      line-height: 16px;
    }
    .alertas {
      display: grid;
      gap: 0.4rem;
      padding: 0 1.5rem 0.75rem;
    }
    .datos-cliente {
      display: grid;
      grid-template-columns: 1fr 1.3fr 2.5fr 1.4fr 1.2fr;
      gap: 1rem 2rem;
      padding: 1rem 1.5rem 1.5rem;
    }
    .datos-cliente > div {
      display: flex;
      flex-direction: column;
      gap: 0.2rem;
    }
    .datos-cliente strong {
      font-weight: 600;
      color: #3c4650;
    }
    .mayus {
      text-transform: uppercase;
    }
    .franja {
      display: grid;
      grid-template-columns: 1.1fr 1fr;
      gap: 2rem;
      background: var(--pgm-fondo-franja);
      padding: 1.5rem;
    }
    .cifras {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 1.5rem;
      border-left: 1px solid var(--pgm-borde-input);
      padding-left: 2rem;
    }
    .cifra-bloque {
      display: flex;
      flex-direction: column;
      align-items: center;
      text-align: center;
    }
    .rojo {
      color: var(--pgm-rojo);
    }
    .chip-titulo {
      display: inline-block;
      background: #4f5b66;
      color: #fff;
      border-radius: 999px;
      padding: 0.1rem 0.8rem;
      font-size: 0.8rem;
      font-weight: 600;
      margin-bottom: 0.5rem;
    }
    .familiar {
      display: block;
    }
    .leyenda {
      font-size: 0.85rem;
      margin-top: 0.25rem;
    }
    .punto-gris {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background: #4f5b66;
    }
    .cabecera-posicion {
      margin-bottom: 1rem;
      gap: 2rem;
    }
    .cabecera-posicion select {
      min-width: 220px;
    }
    .productos .icono-ramo {
      color: #6c7b88;
      width: 40px;
    }
    .ramo-txt {
      font-size: 0.8rem;
      text-transform: uppercase;
      color: var(--pgm-texto-2);
    }
    .fechas {
      font-size: 0.88rem;
      line-height: 1.5;
    }
    .acciones details {
      position: relative;
    }
    .acciones summary {
      color: var(--pgm-rojo);
      cursor: pointer;
      list-style: none;
    }
    .acciones .menu {
      position: absolute;
      right: 0;
      z-index: 5;
      min-width: 240px;
      display: grid;
      gap: 0.5rem;
      background: #fff;
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
      padding: 0.75rem 1rem;
    }
    .flecha {
      color: var(--pgm-rojo);
    }
    @media (max-width: 1100px) {
      .datos-cliente,
      .franja,
      .cifras {
        grid-template-columns: 1fr 1fr;
      }
    }
  `,
})
export class FichaClientePageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  private readonly router = inject(Router);
  readonly store = inject(ContextoStore);
  readonly V = Visibilidad;
  readonly id = input.required<string>();

  readonly cliente = signal<Cliente | null>(null);
  readonly polizas = signal<Poliza[]>([]);
  readonly recibos = signal<Recibo[]>([]);
  readonly prestaciones = signal<Prestacion[]>([]);
  readonly presupuestos = signal<Presupuesto[]>([]);
  readonly oportunidades = signal<Oportunidad[]>([]);
  readonly gestiones = signal<GestionComercial[]>([]);
  readonly errorGestiones = signal<string | null>(null);
  readonly sgo = signal<SolicitudSgo[]>([]);
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly principal = signal<Principal>('posicion');
  readonly pestana = signal<Pestana>('productos');
  readonly filtroRamo = signal<Ramo | null>(null);
  readonly verAlertas = signal(false);
  readonly filtroEstado = signal<string>('EN_VIGOR');
  readonly llamadaId = signal<string | null>(null);
  readonly polizasFiltradas = computed(() => {
    const f = this.filtroEstado();
    const r = this.filtroRamo();
    return this.polizas().filter(
      (p) =>
        (!f || (f === 'EN_VIGOR' ? p.estado === 'EN_VIGOR' : p.estado !== 'EN_VIGOR')) &&
        (!r || p.ramo === r),
    );
  });
  readonly totalPrima = computed(() =>
    this.polizas()
      .filter((p) => p.estado === 'EN_VIGOR')
      .reduce((t, p) => t + (p.primaAnual ?? 0), 0),
  );
  readonly edad = computed(() => {
    const f = this.cliente()?.fechaNacimiento;
    if (!f) return null;
    return Math.floor((Date.now() - new Date(f).getTime()) / (365.25 * 24 * 3600 * 1000));
  });
  readonly contadores = computed(() => {
    const c = Object.fromEntries(
      RAMOS.map((r) => [r, { polizas: 0, vencimientos: 0, presupuestos: 0 }]),
    ) as Record<Ramo, ContadorRamo>;
    this.polizas()
      .filter((p) => p.estado === 'EN_VIGOR')
      .forEach((p) => c[p.ramo].polizas++);
    this.oportunidades().forEach((o) => c[o.ramo].vencimientos++);
    this.presupuestos().forEach((p) => c[p.ramo].presupuestos++);
    return c;
  });

  readonly dialogo = signal(false);
  readonly bloqueoVto = signal(false);
  filtroPpto = { ramo: '', numero: '' };
  readonly hayFiltroPresupuestos = () => !!(this.filtroPpto.ramo || this.filtroPpto.numero);
  readonly ramosPpto = computed(() => [...new Set(this.presupuestos().map((p) => p.ramo))]);
  readonly presupuestosFiltrados = computed(() =>
    this.presupuestos().filter(
      (p) =>
        (!this.filtroPpto.ramo || p.ramo === this.filtroPpto.ramo) &&
        (!this.filtroPpto.numero || p.numero.includes(this.filtroPpto.numero)),
    ),
  );
  readonly pasoDialogo = signal(0);
  readonly tarifa = signal<TarificacionResultado | null>(null);
  readonly borradorId = signal<string | null>(null);
  readonly errorDialogo = signal<string | null>(null);
  formulario = { producto: '', codigoPostal: '', copago: false };
  edadesTexto = '';
  readonly esSalud = () => this.formulario.producto.startsWith('SALUD');
  readonly puedeAvanzar = () => this.pasoDialogo() !== 0 || !!this.formulario.producto;

  readonly colRecibos: Columna<Recibo>[] = [
    { clave: 'numero', titulo: 'Recibo' },
    { clave: 'polizaNumero', titulo: 'Póliza' },
    {
      clave: 'ramo',
      titulo: 'Ramo',
      formato: (v) => ETIQUETA_RAMO[v as keyof typeof ETIQUETA_RAMO] ?? `${v}`,
    },
    { clave: 'estado', titulo: 'Estado', formato: textoEstado, etiqueta: badgeEstado },
    { clave: 'importe', titulo: 'Importe (€)' },
    { clave: 'fechaEmision', titulo: 'Emisión' },
    { clave: 'fechaVencimiento', titulo: 'Vencimiento' },
    { clave: 'formaPago', titulo: 'Forma de pago' },
  ];
  readonly colPrestaciones: Columna<Prestacion>[] = [
    { clave: 'numero', titulo: 'Expediente' },
    { clave: 'polizaNumero', titulo: 'Póliza' },
    { clave: 'ramo', titulo: 'Ramo' },
    { clave: 'tipo', titulo: 'Tipo' },
    { clave: 'estado', titulo: 'Estado', formato: textoEstado, etiqueta: badgeEstado },
    { clave: 'fechaOcurrencia', titulo: 'Ocurrencia' },
    { clave: 'descripcion', titulo: 'Descripción' },
    { clave: 'tramitador', titulo: 'Tramitador' },
  ];
  readonly colPresupuestos: Columna<Presupuesto>[] = [
    { clave: 'numero', titulo: 'Presupuesto' },
    { clave: 'ramo', titulo: 'Ramo' },
    { clave: 'producto', titulo: 'Producto' },
    { clave: 'estado', titulo: 'Estado', formato: textoEstado, etiqueta: badgeEstado },
    { clave: 'fecha', titulo: 'Fecha' },
    { clave: 'fechaCaducidad', titulo: 'Caduca' },
    { clave: 'primaAnual', titulo: 'Prima anual (€)' },
  ];
  readonly colOportunidades: Columna<Oportunidad>[] = [
    { clave: 'tipo', titulo: 'Tipo' },
    { clave: 'ramo', titulo: 'Ramo' },
    { clave: 'polizaNumero', titulo: 'Póliza' },
    { clave: 'fecha', titulo: 'Fecha' },
    { clave: 'prioridad', titulo: 'Prioridad' },
    { clave: 'descripcion', titulo: 'Descripción' },
  ];
  readonly colGestiones: Columna<GestionComercial>[] = [
    { clave: 'fecha', titulo: 'Fecha' },
    { clave: 'tipo', titulo: 'Tipo' },
    { clave: 'estado', titulo: 'Estado', formato: textoEstado, etiqueta: badgeEstado },
    { clave: 'descripcion', titulo: 'Descripción' },
    { clave: 'gestor', titulo: 'Gestor' },
    { clave: 'origen', titulo: 'Origen' },
  ];
  readonly colSgo: Columna<SolicitudSgo>[] = [
    { clave: 'id', titulo: 'Solicitud' },
    { clave: 'tipo', titulo: 'Tipo' },
    { clave: 'estado', titulo: 'Estado', formato: textoEstado, etiqueta: badgeEstado },
    { clave: 'fecha', titulo: 'Fecha' },
    { clave: 'descripcion', titulo: 'Descripción' },
  ];

  constructor() {
    effect(() => {
      const id = this.id();
      if (id) void this.cargar(id);
    });
  }

  ramo(r: Poliza['ramo']): string {
    return ETIQUETA_RAMO[r];
  }

  lanzaderaDe(p: Poliza): Lanzadera | undefined {
    return this.lanzaderas().find((l) => l.codigo === p.lanzadera || l.ramo === p.ramo);
  }

  async cargar(id: string): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    this.cliente.set(null);
    this.llamadaId.set(null);
    try {
      const c = await firstValueFrom(this.repo.fichaCliente(id));
      this.cliente.set(c);
      this.principal.set('posicion');
      this.pestana.set('productos');
      this.filtroRamo.set(null);
      this.filtroEstado.set(c.estado === 'ANULADO' ? 'ANULADA' : 'EN_VIGOR');
      void this.auditar('ficha');
      const [pol, rec, pre, ppt, opo, sgo, lan] = await Promise.all([
        firstValueFrom(this.repo.productos(id)),
        firstValueFrom(this.repo.recibosCliente(id)),
        firstValueFrom(this.repo.prestacionesCliente(id)),
        firstValueFrom(this.repo.presupuestos(id)),
        firstValueFrom(this.repo.oportunidades(id)),
        firstValueFrom(this.repo.solicitudesSgo(id)),
        firstValueFrom(this.repo.lanzaderas()),
      ]);
      this.polizas.set(pol.items);
      this.recibos.set(rec.items);
      this.prestaciones.set(pre.items);
      this.presupuestos.set(ppt.items);
      this.oportunidades.set(opo.items);
      this.sgo.set(sgo.items);
      this.lanzaderas.set(lan.items);
      if (this.store.puede(Visibilidad.GESTIONES_SGC30)) {
        try {
          this.gestiones.set((await firstValueFrom(this.repo.gestiones(id))).items);
          this.errorGestiones.set(null);
        } catch (e) {
          this.gestiones.set([]);
          this.errorGestiones.set((e as Error).message);
        }
      }
    } catch (e) {
      this.error.set((e as Error).message);
    } finally {
      this.cargando.set(false);
    }
  }

  async llamar(c: Cliente): Promise<void> {
    try {
      this.llamadaId.set((await firstValueFrom(this.repo.llamar(c.id, c.telefono))).idLlamada);
    } catch (e) {
      this.error.set((e as Error).message);
    }
  }

  async auditar(accion: string): Promise<void> {
    const c = this.cliente();
    if (!c) return;
    try {
      await firstValueFrom(
        this.repo.auditar({ accion, clienteId: c.id, pantalla: 'ficha-cliente' }),
      );
    } catch {
      /* la auditoría no debe bloquear la navegación */
    }
  }

  cuentaEstado(e: string): number {
    return this.polizas().filter((p) =>
      e === 'EN_VIGOR' ? p.estado === 'EN_VIGOR' : p.estado !== 'EN_VIGOR',
    ).length;
  }

  iconoRamo(r: Ramo) {
    return ICONO_RAMO[r];
  }

  badge(v: unknown): string {
    return badgeEstado(v);
  }

  texto(v: unknown): string {
    return textoEstado(v);
  }

  filtrarRamo(r: Ramo): void {
    this.principal.set('posicion');
    this.pestana.set('productos');
    this.filtroEstado.set('');
    this.filtroRamo.set(r);
  }

  irRecibo(r: Recibo): void {
    void this.router.navigate(['/recibos', r.numero]);
  }

  exportarProductos(): void {
    exportarCsv(
      'productos',
      [
        'Ramo',
        'Producto',
        'Póliza',
        'Riesgo',
        'Prima anual',
        'Forma de pago',
        'Efecto',
        'Vencimiento',
        'Estado',
      ],
      this.polizasFiltradas().map((p) => [
        this.ramo(p.ramo),
        p.producto,
        p.numero,
        p.riesgo,
        `${p.primaAnual}`,
        p.formaPago,
        p.fechaEfecto,
        p.fechaVencimiento,
        p.estado,
      ]),
    );
  }

  consultarPresupuesto(p: Presupuesto): void {
    void this.auditar('presupuesto:' + p.numero);
    const lanzadera = this.lanzaderas().find((l) => l.ramo === p.ramo);
    if (lanzadera) {
      window.open(lanzadera.url, '_blank', 'noopener');
    }
  }

  abrirDialogo(ramo?: Ramo): void {
    if (!this.store.puede(Visibilidad.ANADIR_VENCIMIENTO)) {
      this.bloqueoVto.set(true);
      return;
    }
    const preseleccion: Partial<Record<Ramo, string>> = {
      SALUD: this.store.puede(Visibilidad.TARIFICACION_SALUD) ? 'SALUD-FAMILIAR' : '',
      AUTOS: 'AUTOS-TR',
      HOGAR: 'HOGAR-PLUS',
    };
    this.formulario = {
      producto: ramo ? (preseleccion[ramo] ?? '') : '',
      codigoPostal: this.cliente()?.direccion.codigoPostal ?? '',
      copago: false,
    };
    this.edadesTexto = '';
    this.tarifa.set(null);
    this.borradorId.set(null);
    this.errorDialogo.set(null);
    this.pasoDialogo.set(0);
    this.dialogo.set(true);
  }

  private solicitud() {
    const edades = this.edadesTexto
      .split(',')
      .map((e) => parseInt(e.trim(), 10))
      .filter((n) => !isNaN(n));
    return {
      clienteId: this.cliente()?.id ?? '',
      producto: this.formulario.producto,
      codigoPostal: this.formulario.codigoPostal,
      edades,
      copago: this.formulario.copago,
    };
  }

  async tarificar(): Promise<void> {
    this.errorDialogo.set(null);
    try {
      this.tarifa.set(await firstValueFrom(this.repo.tarificarSalud(this.solicitud())));
    } catch (e) {
      this.errorDialogo.set((e as Error).message);
    }
  }

  async guardarBorrador(): Promise<void> {
    this.errorDialogo.set(null);
    try {
      this.borradorId.set(
        (await firstValueFrom(this.repo.guardarBorradorSalud(this.solicitud()))).id,
      );
      void this.auditar('borrador:' + this.formulario.producto);
    } catch (e) {
      this.errorDialogo.set((e as Error).message);
    }
  }
}
