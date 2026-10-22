import { CommonModule } from '@angular/common';
import { Component, computed, effect, inject, input, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import {
  ActividadComercial,
  CatalogoItem,
  FiltroActividad,
  FiltroOportunidades,
  GestionComercial,
  GestionDetalle,
  Oportunidad,
  OportunidadDetalle,
  Ramo,
  ResumenOportunidades,
  Visibilidad,
} from '../../domain/models/api.models';
import { IconoComponent } from './icono.component';
import { Columna, TablaExportableComponent } from './tabla-exportable.component';

/** Textos literales de PGM (Appian TEST, ronda de pruebas 2026-10-20). */
export const TEXTOS_GC = {
  sinVencimientos: 'No hay vencimientos para este cliente',
  sinCoincidencias: 'No se encontraron vencimientos que coincidan con los criterios seleccionados.',
  sinActividad: 'No hay actividades comerciales para este cliente',
  sinGestiones: 'No hay gestiones para este cliente',
  sinPermisoGestiones: 'No tienes permiso para ver las gestiones',
  puedesSgc20: 'Puedes realizarla desde SGC 2.0',
  accesoSgc20: 'Acceso a SGC 2.0',
  avisoRgpd: 'Antes de añadir una nueva actividad comercial gestione la cláusula RGPD.',
  errorDetalleGestion: 'Parece que no puedes ver el detalle de la gestión',
  pruebaRefrescar: 'Prueba a refrescar el listado de gestiones',
  exitoActividad: 'Nueva actividad añadida con éxito.',
  errorActividad: 'Ha ocurrido un error al añadir la nueva actividad.',
  contactaAdmin: 'Contacta con el administrador de la aplicación si consideras que debes acceder',
  accionNoDisponible: (u: string) =>
    `Esta acción aún no está disponible en PGM para tu usuario (${u})`,
};
export const PESTANAS_GESTION_COMERCIAL = [
  'Vencimientos',
  'Actividad Comercial',
  'Gestiones',
] as const;
export const COLUMNAS_VENCIMIENTOS_SAIL = [
  'Venc. / Oport.',
  'Clase de Vcto.',
  'Producto / Riesgo',
  'F. Venci. / Opor.',
  'Prima / Saldo',
  'Entidad competencia',
  'Usuario',
  'Comentarios',
  'Anexos',
] as const;

const fechaCorta = (v: unknown) => (v ? new Date(`${v}`).toLocaleDateString('es-ES') : '-');
const fechaHora = (v: unknown) =>
  v ? new Date(`${v}`).toLocaleString('es-ES', { dateStyle: 'short', timeStyle: 'short' }) : '-';
const euros = (v: unknown) =>
  v === null || v === undefined ? '-' : `${Number(v).toLocaleString('es-ES')} €`;

/**
 * Pestaña «Gestión comercial» de la ficha (PGM_FichaCliente_v2 › tab 2): Vencimientos (PGO), Actividad comercial
 * (iMediador) y Gestiones (SGC 3.0), con la degradación por perfil de Appian: el BFF decide, la SPA pinta los textos.
 */
@Component({
  selector: 'pgm-gestion-comercial-cliente',
  standalone: true,
  imports: [CommonModule, FormsModule, IconoComponent, TablaExportableComponent],
  template: `
    <div class="subtabs" role="tablist">
      @for (etiqueta of pestanas; track etiqueta) {
        <button
          role="tab"
          [class.activa]="seccion() === seccionDeEtiqueta(etiqueta)"
          (click)="seccion.set(seccionDeEtiqueta(etiqueta))"
        >
          {{ etiqueta }}
        </button>
      }
    </div>

    @switch (seccion()) {
      @case ('vencimientos') {
        <div class="chips-estado">
          <button class="chip" [class.chip-ok]="filtro.clase === null" (click)="setClase(null)">
            Todos {{ resumen()?.todos ?? 0 }}
          </button>
          <button
            class="chip"
            [class.chip-ok]="filtro.clase === 'COMPLETO'"
            (click)="setClase('COMPLETO')"
          >
            Completo {{ resumen()?.completos ?? 0 }}
          </button>
          <button
            class="chip"
            [class.chip-ok]="filtro.clase === 'INCOMPLETO'"
            (click)="setClase('INCOMPLETO')"
          >
            Incompleto {{ resumen()?.incompletos ?? 0 }}
          </button>
          <button class="btn-enlace" (click)="verFiltros.set(!verFiltros())">
            <pgm-icono nombre="buscar" /> Filtros
          </button>
        </div>
        @if (verFiltros()) {
          <form class="filtros" (ngSubmit)="cargarOportunidades()">
            <label
              >Producto
              <select
                [(ngModel)]="filtro.producto"
                name="producto"
                [disabled]="productosVencimientos().length === 0"
              >
                <option [ngValue]="null" disabled>{{
                  productosVencimientos().length === 0 ? 'Sin opciones' : 'Selecciona'
                }}</option>
                @for (r of productosVencimientos(); track r) {
                  <option [ngValue]="r">{{ etiquetaProducto(r) }}</option>
                }
              </select></label
            >
            <label>Fecha Desde <input type="date" [(ngModel)]="filtro.desde" name="desde" /></label>
            <label>Fecha Hasta <input type="date" [(ngModel)]="filtro.hasta" name="hasta" /></label>
            <fieldset class="filtro-contratado">
              <legend>Contratado</legend>
              <label>
                <input type="radio" name="contratado" [(ngModel)]="filtro.contratado" [value]="true" />
                Sí
              </label>
              <label>
                <input
                  type="radio"
                  name="contratado"
                  [(ngModel)]="filtro.contratado"
                  [value]="false"
                />
                No
              </label>
            </fieldset>
            <button type="button" class="btn-secundario" (click)="limpiarFiltros()">Limpiar</button>
            <button type="submit" class="btn">Ver resultados</button>
          </form>
        }
        @if (errorOportunidades()) {
          <div class="alerta alerta-error">
            <pgm-icono nombre="aviso" /> {{ errorOportunidades() }}
          </div>
        } @else {
          <pgm-tabla-exportable
            titulo="Vencimientos"
            nombreFichero="vencimientos"
            [columnas]="colOportunidades"
            [filas]="oportunidades()"
            [mensajeVacio]="hayFiltro() ? textos.sinCoincidencias : textos.sinVencimientos"
            [navegable]="true"
            (filaSeleccionada)="abrirOportunidad($event)"
          />
        }
        @if (detalleOportunidad(); as d) {
          <section class="panel-detalle" aria-label="Detalle de vencimiento">
            <header>
              <h3>Detalle de vencimiento · {{ d.oportunidad.ramo }} · {{ d.oportunidad.tipo }}</h3>
              <button
                class="btn-icono"
                aria-label="Cerrar detalle"
                (click)="detalleOportunidad.set(null)"
              >
                <pgm-icono nombre="cerrar" />
              </button>
            </header>
            <div class="bloques">
              <dl>
                <dt>Datos Generales</dt>
                @for (e of entradas(d.datosGenerales); track e[0]) {
                  <dd>
                    <b>{{ e[0] }}:</b> {{ e[1] }}
                  </dd>
                }
              </dl>
              <dl>
                <dt>Datos Producto</dt>
                @for (e of entradas(d.datosProducto); track e[0]) {
                  <dd>
                    <b>{{ e[0] }}:</b> {{ e[1] }}
                  </dd>
                }
              </dl>
              <dl>
                <dt>Datos Riesgo</dt>
                @for (e of entradas(d.datosRiesgo); track e[0]) {
                  <dd>
                    <b>{{ e[0] }}:</b> {{ e[1] }}
                  </dd>
                }
              </dl>
            </div>
            <h4>Histórico de observaciones</h4>
            <table class="tabla">
              <thead>
                <tr>
                  <th>Fecha observación</th>
                  <th>Fecha actualización</th>
                  <th>Observaciones</th>
                  <th>Usuario</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                @for (o of d.observaciones; track o.id) {
                  <tr>
                    <td>{{ fh(o.fecha) }}</td>
                    <td>{{ fh(o.fechaActualizacion) }}</td>
                    <td>{{ o.texto }}</td>
                    <td>{{ o.usuario }}</td>
                    <td>
                      <button class="btn-enlace" (click)="eliminarObservacion(d, o.id)">
                        Eliminar
                      </button>
                    </td>
                  </tr>
                } @empty {
                  <tr>
                    <td colspan="5" class="muted">Sin observaciones</td>
                  </tr>
                }
              </tbody>
            </table>
            <form class="filtros" (ngSubmit)="anadirObservacion(d)">
              <input
                [(ngModel)]="nuevaObservacion"
                name="obs"
                placeholder="Nueva observación"
                required
              />
              <button class="btn" type="submit" [disabled]="!nuevaObservacion.trim()">
                Añadir observación
              </button>
            </form>
            @if (d.documentos.length) {
              <h4>Documentos anexos</h4>
              <ul>
                @for (doc of d.documentos; track doc.id) {
                  <li>{{ doc.nombre }} ({{ fh(doc.fecha) }})</li>
                }
              </ul>
            }
          </section>
        }
        @if (nuevoVencimiento()) {
          <section class="panel-detalle" aria-label="Añadir Vencimiento / Presupuesto">
            <header>
              <h3>Añadir Vencimiento / Presupuesto</h3>
              <button class="btn-icono" aria-label="Cerrar" (click)="nuevoVencimiento.set(false)">
                <pgm-icono nombre="cerrar" />
              </button>
            </header>
            <form class="formulario-grid" (ngSubmit)="crearVencimiento()">
              <label
                >Ramo *
                <select [(ngModel)]="alta.ramo" name="ramo" required>
                  @for (r of ramos; track r) {
                    <option [ngValue]="r">{{ r }}</option>
                  }
                </select></label
              >
              <label
                >Tipo
                <select [(ngModel)]="alta.tipo" name="tipoAlta">
                  <option value="VENCIMIENTO">Vencimiento</option>
                  <option value="OPORTUNIDAD">Oportunidad</option>
                </select></label
              >
              <label
                >Fecha de vencimiento *
                <input type="date" [(ngModel)]="alta.fecha" name="fecha" required
              /></label>
              <label
                >Entidad competencia
                <select [(ngModel)]="alta.entidadCompetencia" name="compania">
                  <option value="">-</option>
                  @for (c of companias(); track c.codigo) {
                    <option [value]="c.nombre">{{ c.nombre }}</option>
                  }
                </select></label
              >
              <label
                >Prima / Saldo
                <input type="number" step="0.01" [(ngModel)]="alta.prima" name="prima"
              /></label>
              <label class="ancho"
                >Comentarios
                <textarea [(ngModel)]="alta.comentarios" name="comentarios" rows="2"></textarea>
              </label>
              <div class="acciones">
                <button type="button" class="btn-secundario" (click)="nuevoVencimiento.set(false)">
                  Cancelar
                </button>
                <button type="submit" class="btn" [disabled]="!alta.ramo || !alta.fecha">
                  Añadir
                </button>
              </div>
            </form>
            @if (mensajeAlta()) {
              <div class="alerta alerta-info">{{ mensajeAlta() }}</div>
            }
          </section>
        }
      }

      @case ('actividad') {
        @if (!store.puede(V.ACTIVIDAD_COMERCIAL)) {
          <div class="alerta alerta-info bloqueo">
            <pgm-icono nombre="info" />
            <div>
              <p>
                <b>{{ textos.accionNoDisponible(nuuma()) }}</b>
              </p>
              <p>{{ textos.puedesSgc20 }}</p>
              <a class="btn-enlace" href="#" (click)="$event.preventDefault()">{{
                textos.accesoSgc20
              }}</a>
            </div>
          </div>
        } @else {
          <form class="filtros" (ngSubmit)="cargarActividad()">
            <label>Desde <input type="date" [(ngModel)]="filtroAct.desde" name="aDesde" /></label>
            <label>Hasta <input type="date" [(ngModel)]="filtroAct.hasta" name="aHasta" /></label>
            <label
              >Gestión Alcanzada
              <select [(ngModel)]="filtroAct.gestionAlcanzada" name="aGestion">
                <option [ngValue]="null">Todas</option>
                @for (n of niveles(); track n.codigo) {
                  <option [value]="n.nombre">{{ n.nombre }}</option>
                }
              </select></label
            >
            <label>Producto <input [(ngModel)]="filtroAct.producto" name="aProducto" /></label>
            <label>Tipo Acción <input [(ngModel)]="filtroAct.tipoAccion" name="aTipo" /></label>
            <button type="button" class="btn-secundario" (click)="limpiarActividad()">
              Limpiar
            </button>
            <button type="submit" class="btn">Ver resultados</button>
            <button
              type="button"
              class="btn"
              style="margin-left:auto"
              (click)="nuevaActividad.set(!nuevaActividad())"
            >
              Nueva actividad alcanzada
            </button>
          </form>
          @if (nuevaActividad()) {
            <section class="panel-detalle" aria-label="Nueva actividad">
              @if (!cliente()?.rgpd && !continuarSinRgpd()) {
                <div class="alerta alerta-info">
                  <pgm-icono nombre="info" /> {{ textos.avisoRgpd }}
                  <button class="btn-secundario" (click)="nuevaActividad.set(false)">ATRÁS</button>
                  <button class="btn" (click)="continuarSinRgpd.set(true)">
                    CONTINUAR SIN RGPD
                  </button>
                </div>
              } @else {
                <form class="formulario-grid" (ngSubmit)="crearActividad()">
                  <label
                    >Gestión alcanzada *
                    <select [(ngModel)]="altaAct.nivelGestion" name="nivel" required>
                      @for (n of niveles(); track n.codigo) {
                        <option [value]="n.nombre">{{ n.nombre }}</option>
                      }
                    </select></label
                  >
                  <label class="ancho"
                    >Comentario
                    <textarea
                      [(ngModel)]="altaAct.comentario"
                      name="comentario"
                      rows="2"
                    ></textarea>
                  </label>
                  <div class="acciones">
                    <button
                      type="button"
                      class="btn-secundario"
                      (click)="nuevaActividad.set(false)"
                    >
                      Cancelar
                    </button>
                    <button type="submit" class="btn" [disabled]="!altaAct.nivelGestion">
                      Guardar
                    </button>
                  </div>
                </form>
              }
              @if (mensajeActividad()) {
                <div class="alerta alerta-info">{{ mensajeActividad() }}</div>
              }
            </section>
          }
          @if (errorActividad()) {
            <div class="alerta alerta-error">
              <pgm-icono nombre="aviso" /> {{ errorActividad() }}
            </div>
          } @else {
            <pgm-tabla-exportable
              titulo="Actividad comercial"
              nombreFichero="actividad-comercial"
              [columnas]="colActividad"
              [filas]="actividad()"
              [mensajeVacio]="textos.sinActividad"
            />
          }
        }
      }

      @case ('gestiones') {
        @if (!store.puede(V.GESTIONES_SGC30)) {
          <div class="alerta alerta-info">
            <pgm-icono nombre="info" /> {{ textos.sinPermisoGestiones }}
            <span>{{ textos.accionNoDisponible(nuuma()) }}… {{ textos.puedesSgc20 }}</span>
            <a class="btn-enlace" [href]="urlSgc20" target="_blank" rel="noopener">
              {{ textos.accesoSgc20 }}
            </a>
          </div>
        } @else {
          <div class="chips-estado">
            <label class="filtro-gestiones"
              >Estado
              <select
                aria-label="Filtro de estado de gestiones"
                [ngModel]="filtroGestion()"
                (ngModelChange)="filtroGestion.set($event)"
              >
                @for (f of filtrosGestion; track f.valor) {
                  <option [value]="f.valor">{{ f.etiqueta }}</option>
                }
              </select>
            </label>
            <button
              class="btn-enlace"
              (click)="cargarGestiones()"
              aria-label="Refrescar el listado de gestiones"
            >
              <pgm-icono nombre="refrescar" /> Refrescar listado
            </button>
          </div>
          @if (errorGestiones()) {
            <div class="alerta alerta-error">
              <pgm-icono nombre="aviso" /> {{ errorGestiones() }}
            </div>
          } @else {
            <pgm-tabla-exportable
              titulo="Gestiones SGC 3.0"
              nombreFichero="gestiones"
              [columnas]="colGestiones"
              [filas]="gestionesVisibles()"
              [mensajeVacio]="textos.sinGestiones"
              [navegable]="true"
              (filaSeleccionada)="abrirGestion($event)"
            />
          }
          @if (errorDetalleGestion()) {
            <div class="alerta alerta-error">
              <pgm-icono nombre="aviso" /> {{ textos.errorDetalleGestion }} ·
              {{ textos.pruebaRefrescar }}
            </div>
          }
          @if (detalleGestion(); as g) {
            <section class="panel-detalle" aria-label="Detalle de gestión">
              <header>
                <h3>{{ g.gestion.tipo }} · {{ texto(g.gestion.estado) }}</h3>
                <div class="acciones">
                  @if (g.gestion.estado === 'ABIERTA') {
                    <button class="btn" (click)="cerrarGestion(g, 'POSITIVA')">
                      Cerrar positiva
                    </button>
                    <button class="btn-secundario" (click)="cerrarGestion(g, 'NEGATIVA')">
                      Cerrar negativa
                    </button>
                  } @else if (g.gestion.estado !== 'CADUCADA') {
                    <button class="btn-secundario" (click)="reabrirGestion(g)">Reabrir</button>
                  }
                  @if (g.gestion.whatsapp) {
                    <a class="btn-secundario" [href]="whatsappUrl()" target="_blank" rel="noopener"
                      >Contactar por WhatsApp</a
                    >
                  }
                  <button
                    class="btn-icono"
                    aria-label="Cerrar detalle"
                    (click)="detalleGestion.set(null)"
                  >
                    <pgm-icono nombre="cerrar" />
                  </button>
                </div>
              </header>
              <div class="bloques">
                <dl>
                  <dt>Gestión</dt>
                  <dd><b>Fecha caducidad:</b> {{ fc(g.gestion.fechaCaducidad) }}</dd>
                  <dd>
                    <b>Probabilidad de conversión:</b>
                    {{ g.gestion.probabilidadConversion ?? '-' }} %
                  </dd>
                  <dd><b>Potencialidad de éxito:</b> {{ g.potencialidad }}</dd>
                  <dd><b>Asignada a:</b> {{ g.asignadaA ?? 'Sin asignar' }}</dd>
                  <dd><b>Agendado:</b> {{ g.gestion.agendado ? 'Sí' : 'No' }}</dd>
                </dl>
                <dl>
                  <dt>Contacto</dt>
                  @for (t of g.telefonos; track t; let i = $index) {
                    <dd>
                      <b>Teléfono {{ i + 1 }}:</b> {{ t }}
                    </dd>
                  }
                  <dd><b>Email:</b> {{ g.email ?? '-' }}</dd>
                </dl>
              </div>
              <h4>Observaciones</h4>
              <table class="tabla">
                <thead>
                  <tr>
                    <th>Fecha</th>
                    <th>Observación</th>
                    <th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  @for (o of g.observaciones; track o.id) {
                    <tr>
                      <td>{{ fh(o.fecha) }}</td>
                      <td>{{ o.texto }}</td>
                      <td>{{ o.usuario }}</td>
                    </tr>
                  } @empty {
                    <tr>
                      <td colspan="3" class="muted">Sin observaciones</td>
                    </tr>
                  }
                </tbody>
              </table>
              <form class="filtros" (ngSubmit)="observarGestion(g)">
                <input
                  [(ngModel)]="nuevaObservacion"
                  name="obsG"
                  placeholder="Nueva observación"
                  required
                />
                <button class="btn" type="submit" [disabled]="!nuevaObservacion.trim()">
                  Añadir
                </button>
              </form>
              <h4>Gestiones alcanzadas</h4>
              <pgm-tabla-exportable
                nombreFichero="gestiones-alcanzadas"
                [columnas]="colActividad"
                [filas]="g.gestionesAlcanzadas"
                mensajeVacio="No hay gestiones alcanzadas para el cliente"
              />
            </section>
          }
        }
      }
    }
  `,
  styles: [
    `
      .chips-estado {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        margin: 0.75rem 0;
        flex-wrap: wrap;
      }
      .filtros {
        display: flex;
        gap: 0.75rem;
        flex-wrap: wrap;
        align-items: flex-end;
        margin: 0.5rem 0 1rem;
      }
      .filtros label {
        display: flex;
        flex-direction: column;
        font-size: 0.8rem;
        color: var(--gris-oscuro, #555);
        gap: 0.2rem;
      }
      .filtro-contratado {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        margin: 0;
        padding: 0;
        border: 0;
      }
      .filtro-contratado legend {
        padding: 0;
        color: var(--gris-oscuro, #555);
        font-size: 0.8rem;
      }
      .filtros .filtro-contratado label {
        flex-direction: row;
        align-items: center;
      }
      .panel-detalle {
        border: 1px solid var(--borde, #ddd);
        border-radius: 6px;
        padding: 1rem;
        margin-top: 1rem;
        background: #fff;
      }
      .panel-detalle header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 1rem;
      }
      .panel-detalle h3 {
        margin: 0;
        font-size: 1rem;
      }
      .panel-detalle h4 {
        margin: 1rem 0 0.4rem;
        font-size: 0.9rem;
      }
      .bloques {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
        gap: 1rem;
      }
      .bloques dl {
        margin: 0;
      }
      .bloques dt {
        font-weight: 600;
        margin-bottom: 0.3rem;
      }
      .bloques dd {
        margin: 0 0 0.2rem;
        font-size: 0.9rem;
      }
      .formulario-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 0.75rem;
        margin-top: 0.75rem;
      }
      .formulario-grid label {
        display: flex;
        flex-direction: column;
        font-size: 0.8rem;
        gap: 0.2rem;
      }
      .formulario-grid .ancho {
        grid-column: 1 / -1;
      }
      .acciones {
        display: flex;
        gap: 0.5rem;
        align-items: center;
        grid-column: 1 / -1;
        justify-content: flex-end;
      }
      .bloqueo {
        align-items: flex-start;
      }
      .bloqueo p {
        margin: 0 0 0.3rem;
      }
    `,
  ],
})
export class GestionComercialClienteComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly store = inject(ContextoStore);
  readonly V = Visibilidad;
  readonly textos = TEXTOS_GC;
  readonly clienteId = input.required<string>();
  readonly cliente = input<{ rgpd: boolean; documento: string } | null>(null);
  readonly ramos: Ramo[] = [
    'AUTOS',
    'HOGAR',
    'SALUD',
    'VIDA',
    'DECESOS',
    'AHORRO',
    'EMPRESAS',
    'OTROS',
  ];

  readonly seccion = signal<'vencimientos' | 'actividad' | 'gestiones'>('vencimientos');
  readonly pestanas = PESTANAS_GESTION_COMERCIAL;
  readonly urlSgc20 = 'https://sgc20.mapfre.net/';
  readonly verFiltros = signal(false);
  readonly oportunidades = signal<Oportunidad[]>([]);
  readonly resumen = signal<ResumenOportunidades | null>(null);
  readonly errorOportunidades = signal<string | null>(null);
  readonly productosVencimientos = computed(() => {
    const productos = this.oportunidades()
      .map(({ ramo }) => ramo)
      .filter((ramo): ramo is Ramo => typeof ramo === 'string' && ramo.length > 0);
    return [...new Set(productos)].sort((a, b) => a.localeCompare(b, 'es'));
  });
  readonly detalleOportunidad = signal<OportunidadDetalle | null>(null);
  readonly nuevoVencimiento = signal(false);
  readonly mensajeAlta = signal<string | null>(null);
  readonly companias = signal<CatalogoItem[]>([]);
  readonly niveles = signal<CatalogoItem[]>([]);
  readonly actividad = signal<ActividadComercial[]>([]);
  readonly errorActividad = signal<string | null>(null);
  readonly nuevaActividad = signal(false);
  readonly continuarSinRgpd = signal(false);
  readonly mensajeActividad = signal<string | null>(null);
  readonly gestiones = signal<GestionComercial[]>([]);
  readonly errorGestiones = signal<string | null>(null);
  readonly detalleGestion = signal<GestionDetalle | null>(null);
  readonly filtrosGestion = [
    { valor: 'VIGENTES', etiqueta: 'Vigentes' },
    { valor: 'TODAS', etiqueta: 'Todas' },
    { valor: 'EN_CURSO', etiqueta: 'En curso' },
    { valor: 'SIN_ASIGNAR', etiqueta: 'Sin asignar' },
    { valor: 'PENDIENTE', etiqueta: 'Pendiente' },
    { valor: 'CERRADAS', etiqueta: 'Cerradas' },
    { valor: 'CERRADA_POSITIVA', etiqueta: 'Cerrada Positiva' },
    { valor: 'CERRADA_NEGATIVA', etiqueta: 'Cerrada Negativa' },
    { valor: 'CADUCADA', etiqueta: 'Caducada' },
  ] as const;
  seccionDeEtiqueta(etiqueta: (typeof PESTANAS_GESTION_COMERCIAL)[number]) {
    return {
      Vencimientos: 'vencimientos',
      'Actividad Comercial': 'actividad',
      Gestiones: 'gestiones',
    }[etiqueta] as 'vencimientos' | 'actividad' | 'gestiones';
  }
  readonly filtroGestion = signal<(typeof this.filtrosGestion)[number]['valor']>('VIGENTES');
  readonly gestionesVisibles = computed(() => {
    const f = this.filtroGestion();
    const abiertas = ['ABIERTA', 'EN_CURSO', 'SIN_ASIGNAR', 'PENDIENTE'];
    if (f === 'TODAS') return this.gestiones();
    if (f === 'VIGENTES') return this.gestiones().filter((g) => abiertas.includes(g.estado));
    if (f === 'CERRADAS') return this.gestiones().filter((g) => g.estado.startsWith('CERRADA'));
    return this.gestiones().filter((g) => g.estado === f);
  });
  readonly errorDetalleGestion = signal(false);
  readonly puedeAnadir = computed(() => this.store.puede(Visibilidad.ANADIR_VENCIMIENTO));
  readonly nuuma = computed(() => this.store.contexto()?.estructura?.nuuma ?? 'sin Nuuma');
  readonly hayFiltro = computed(
    () =>
      !!(
        this.filtro.producto ||
        this.filtro.desde ||
        this.filtro.hasta ||
        this.filtro.contratado !== null ||
        this.filtro.clase !== null
      ),
  );
  readonly whatsappUrl = computed(() => {
    const doc = this.cliente()?.documento ?? '';
    return `https://conversa-pre.mapfre.es/tasks?data=${btoa(doc)}`;
  });

  filtro: FiltroOportunidades & { clase: Oportunidad['clase'] } = {
    producto: null,
    tipo: null,
    desde: null,
    hasta: null,
    contratado: null,
    clase: null,
  };
  filtroAct: FiltroActividad = {
    desde: null,
    hasta: null,
    gestionAlcanzada: null,
    producto: null,
    tipoAccion: null,
  };
  alta: {
    ramo: Ramo | null;
    tipo: Oportunidad['tipo'];
    fecha: string;
    entidadCompetencia: string;
    prima: number | null;
    comentarios: string;
  } = {
    ramo: null,
    tipo: 'VENCIMIENTO',
    fecha: '',
    entidadCompetencia: '',
    prima: null,
    comentarios: '',
  };
  altaAct = { nivelGestion: '', comentario: '' };
  nuevaObservacion = '';

  readonly colOportunidades: Columna<Oportunidad>[] = [
    {
      clave: 'tipo',
      titulo: 'Venc. / Oport.',
      formato: (v) => (v === 'VENCIMIENTO' ? 'Vencimiento' : 'Oportunidad'),
    },
    {
      clave: 'clase',
      titulo: 'Clase de Vcto.',
      formato: (v) => `${v ?? '-'}`,
      etiqueta: (v) => `badge${v === 'COMPLETO' ? '' : v === 'INCOMPLETO' ? ' naranja' : ' gris'}`,
    },
    {
      clave: 'ramo',
      titulo: 'Producto / Riesgo',
      formato: (v, f) => `${v}${f.polizaNumero ? ' · ' + f.polizaNumero : ''}`,
    },
    { clave: 'fecha', titulo: 'F. Venci. / Opor.', formato: fechaCorta },
    { clave: 'prima', titulo: 'Prima / Saldo', formato: euros },
    { clave: 'entidadCompetencia', titulo: 'Entidad competencia', formato: (v) => `${v ?? '-'}` },
    { clave: 'usuario', titulo: 'Usuario', formato: (v) => `${v ?? '-'}` },
    { clave: 'comentarios', titulo: 'Comentarios', formato: (v) => `${v ?? ''}` },
    { clave: 'anexos', titulo: 'Anexos', formato: (v) => (Number(v) > 0 ? `${v} doc.` : '-') },
  ];
  readonly colActividad: Columna<ActividadComercial>[] = [
    { clave: 'fecha', titulo: 'Fecha y hora', formato: fechaHora },
    { clave: 'gestionAlcanzada', titulo: 'Gestión Alcanzada' },
    { clave: 'usuario', titulo: 'Usuario' },
    { clave: 'accion', titulo: 'Acción' },
    { clave: 'tipoAccion', titulo: 'Tipo de acción' },
    { clave: 'comentarios', titulo: 'Comentarios', formato: (v) => `${v ?? ''}` },
    { clave: 'producto', titulo: 'Producto', formato: (v) => `${v ?? '-'}` },
    { clave: 'prima', titulo: 'Prima', formato: euros },
  ];
  readonly colGestiones: Columna<GestionComercial>[] = [
    { clave: 'fechaCaducidad', titulo: 'F. caducidad', formato: fechaCorta },
    {
      clave: 'tipo',
      titulo: 'Acci. Comercial',
      formato: (v, f) => `${v}${f.whatsapp ? ' · WhatsApp' : ''}`,
    },
    { clave: 'descripcion', titulo: 'Comentarios' },
    {
      clave: 'probabilidadConversion',
      titulo: 'Prob.',
      formato: (v) => (v === null ? '-' : `${v} %`),
    },
    {
      clave: 'estado',
      titulo: 'Estado',
      formato: (v) => `${v}`.replace(/_/g, ' '),
      etiqueta: (v) =>
        `badge${`${v}`.startsWith('CERRADA') ? ' gris' : v === 'CADUCADA' ? ' rojo' : ' naranja'}`,
    },
    { clave: 'agendado', titulo: 'Agendado', formato: (v) => (v ? '✔' : '') },
    { clave: 'gestor', titulo: 'Usuario' },
  ];

  constructor() {
    effect(() => {
      const id = this.clienteId();
      if (id) {
        void this.cargarTodo();
      }
    });
  }

  entradas(o: Record<string, string>): [string, string][] {
    return Object.entries(o ?? {});
  }
  fh = fechaHora;
  fc = fechaCorta;
  texto(v: unknown): string {
    return `${v ?? ''}`.replace(/_/g, ' ');
  }

  etiquetaProducto(producto: Ramo): string {
    const normalizado = producto.toLocaleLowerCase('es');
    return normalizado.charAt(0).toLocaleUpperCase('es') + normalizado.slice(1);
  }

  async cargarTodo(): Promise<void> {
    this.detalleOportunidad.set(null);
    this.detalleGestion.set(null);
    await Promise.all([this.cargarOportunidades(), this.cargarResumen()]);
    if (this.store.puede(Visibilidad.ACTIVIDAD_COMERCIAL)) {
      await this.cargarActividad();
      void this.cargarCatalogos();
    }
    if (this.store.puede(Visibilidad.GESTIONES_SGC30)) {
      await this.cargarGestiones();
    }
  }

  setClase(c: Oportunidad['clase']): void {
    this.filtro.clase = c;
    void this.cargarOportunidades();
  }

  limpiarFiltros(): void {
    this.filtro = {
      producto: null,
      tipo: null,
      desde: null,
      hasta: null,
      contratado: null,
      clase: null,
    };
    void this.cargarOportunidades();
  }

  async cargarOportunidades(): Promise<void> {
    try {
      this.oportunidades.set(
        (await firstValueFrom(this.repo.oportunidades(this.clienteId(), this.filtro))).items,
      );
      this.errorOportunidades.set(null);
    } catch (e) {
      this.oportunidades.set([]);
      this.errorOportunidades.set((e as Error).message);
    }
  }

  async cargarResumen(): Promise<void> {
    try {
      this.resumen.set(await firstValueFrom(this.repo.resumenOportunidades(this.clienteId())));
    } catch {
      this.resumen.set(null);
    }
  }

  async abrirOportunidad(o: Oportunidad): Promise<void> {
    try {
      this.detalleOportunidad.set(await firstValueFrom(this.repo.oportunidad(o.id)));
    } catch (e) {
      this.errorOportunidades.set((e as Error).message);
    }
  }

  async crearVencimiento(): Promise<void> {
    if (!this.alta.ramo || !this.alta.fecha) return;
    try {
      await firstValueFrom(
        this.repo.crearOportunidad(this.clienteId(), {
          ramo: this.alta.ramo,
          tipo: this.alta.tipo,
          fecha: this.alta.fecha,
          entidadCompetencia: this.alta.entidadCompetencia || undefined,
          prima: this.alta.prima,
          comentarios: this.alta.comentarios || undefined,
        }),
      );
      this.mensajeAlta.set('Se ha añadido el vencimiento/la oportunidad con éxito');
      this.alta = {
        ramo: null,
        tipo: 'VENCIMIENTO',
        fecha: '',
        entidadCompetencia: '',
        prima: null,
        comentarios: '',
      };
      await Promise.all([this.cargarOportunidades(), this.cargarResumen()]);
    } catch (e) {
      this.mensajeAlta.set(
        `No ha sido posible añadir el vencimiento/la oportunidad. Por favor, inténtelo de nuevo. (${(e as Error).message})`,
      );
    }
  }

  async anadirObservacion(d: OportunidadDetalle): Promise<void> {
    const texto = this.nuevaObservacion.trim();
    if (!texto) return;
    try {
      await firstValueFrom(this.repo.observarOportunidad(d.oportunidad.id, texto));
      this.nuevaObservacion = '';
      this.detalleOportunidad.set(await firstValueFrom(this.repo.oportunidad(d.oportunidad.id)));
    } catch (e) {
      this.errorOportunidades.set((e as Error).message);
    }
  }

  async eliminarObservacion(d: OportunidadDetalle, obsId: string): Promise<void> {
    try {
      await firstValueFrom(this.repo.eliminarObservacionOportunidad(d.oportunidad.id, obsId));
      this.detalleOportunidad.set(await firstValueFrom(this.repo.oportunidad(d.oportunidad.id)));
    } catch (e) {
      this.errorOportunidades.set((e as Error).message);
    }
  }

  async cargarCatalogos(): Promise<void> {
    try {
      const [n, c] = await Promise.all([
        firstValueFrom(this.repo.catalogoComercial('NIVELES_GESTION')),
        firstValueFrom(this.repo.catalogoComercial('COMPANIAS')),
      ]);
      this.niveles.set(n.items);
      this.companias.set(c.items);
    } catch {
      /* los catálogos no bloquean la pestaña */
    }
  }

  limpiarActividad(): void {
    this.filtroAct = {
      desde: null,
      hasta: null,
      gestionAlcanzada: null,
      producto: null,
      tipoAccion: null,
    };
    void this.cargarActividad();
  }

  async cargarActividad(): Promise<void> {
    try {
      this.actividad.set(
        (await firstValueFrom(this.repo.actividadComercial(this.clienteId(), this.filtroAct)))
          .items,
      );
      this.errorActividad.set(null);
    } catch (e) {
      this.actividad.set([]);
      this.errorActividad.set((e as Error).message);
    }
  }

  async crearActividad(): Promise<void> {
    try {
      await firstValueFrom(
        this.repo.crearActividad(this.clienteId(), {
          nivelGestion: this.altaAct.nivelGestion,
          comentario: this.altaAct.comentario || undefined,
          sinRgpd: this.continuarSinRgpd(),
        }),
      );
      this.mensajeActividad.set(TEXTOS_GC.exitoActividad);
      this.altaAct = { nivelGestion: '', comentario: '' };
      await this.cargarActividad();
    } catch {
      this.mensajeActividad.set(TEXTOS_GC.errorActividad);
    }
  }

  async cargarGestiones(): Promise<void> {
    try {
      this.gestiones.set((await firstValueFrom(this.repo.gestiones(this.clienteId()))).items);
      this.errorGestiones.set(null);
    } catch (e) {
      this.gestiones.set([]);
      this.errorGestiones.set((e as Error).message);
    }
  }

  async abrirGestion(g: GestionComercial): Promise<void> {
    try {
      this.detalleGestion.set(await firstValueFrom(this.repo.gestion(g.id)));
      this.errorDetalleGestion.set(false);
    } catch {
      this.detalleGestion.set(null);
      this.errorDetalleGestion.set(true);
    }
  }

  async cerrarGestion(g: GestionDetalle, resultado: 'POSITIVA' | 'NEGATIVA'): Promise<void> {
    if (!window.confirm(`¿Cerrar la gestión como ${resultado.toLowerCase()}? Sí, cerrar`)) return;
    try {
      await firstValueFrom(this.repo.cerrarGestion(g.gestion.id, resultado));
      await this.cargarGestiones();
      await this.abrirGestion(g.gestion);
    } catch (e) {
      this.errorGestiones.set((e as Error).message);
    }
  }

  async reabrirGestion(g: GestionDetalle): Promise<void> {
    try {
      await firstValueFrom(this.repo.reabrirGestion(g.gestion.id));
      await this.cargarGestiones();
      await this.abrirGestion(g.gestion);
    } catch (e) {
      this.errorGestiones.set((e as Error).message);
    }
  }

  async observarGestion(g: GestionDetalle): Promise<void> {
    const texto = this.nuevaObservacion.trim();
    if (!texto) return;
    try {
      await firstValueFrom(this.repo.observarGestion(g.gestion.id, texto));
      this.nuevaObservacion = '';
      await this.abrirGestion(g.gestion);
    } catch (e) {
      this.errorGestiones.set((e as Error).message);
    }
  }
}
