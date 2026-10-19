import { CurrencyPipe, DatePipe } from '@angular/common';
import { Component, computed, effect, inject, input, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
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
  Recibo,
  SolicitudSgo,
  TarificacionResultado,
  Visibilidad,
} from '../../domain/models/api.models';
import { ETIQUETA_RAMO } from '../components/carrusel-ramos.component';
import { DialogoPasosComponent } from '../components/dialogo-pasos.component';
import { EstadoComponent } from '../components/estado.component';
import { IndicadoresClienteComponent } from '../components/indicadores-cliente.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

type Pestana = 'productos' | 'recibos' | 'prestaciones' | 'presupuestos' | 'gestiones' | 'sgo';

/** /clientes/:id — ficha 360 del cliente: indicadores, alertas, familia, productos por ramo, recibos, prestaciones, gestión comercial. */
@Component({
  selector: 'pgm-ficha-cliente-page',
  imports: [
    DatePipe,
    CurrencyPipe,
    FormsModule,
    RouterLink,
    IndicadoresClienteComponent,
    TablaExportableComponent,
    EstadoComponent,
    DialogoPasosComponent,
  ],
  template: `
    <pgm-estado [cargando]="cargando()" [error]="error()" />
    @if (cliente(); as c) {
      <section class="card">
        <div class="row">
          <h1>{{ c.nombre }} {{ c.apellidos }}</h1>
          <span class="muted">{{ c.tipoDocumento }} {{ c.documento }}</span>
          <span class="spacer"></span>
          <button class="btn btn-secundario" (click)="llamar(c)">📞 Llamar</button>
          <button class="btn" (click)="abrirDialogo()">Vto. / Ppto.</button>
        </div>
        <pgm-indicadores-cliente [c]="c" />
        <div class="grid grid-3" style="margin-top:1rem">
          <dl class="datos">
            <dt>Nacimiento</dt>
            <dd>{{ c.fechaNacimiento | date: 'dd/MM/yyyy' }} · {{ c.nacionalidad }}</dd>
            <dt>Dirección</dt>
            <dd>
              {{ c.direccion.via }} {{ c.direccion.numero }}, {{ c.direccion.codigoPostal }}
              {{ c.direccion.localidad }} ({{ c.direccion.provincia }})
            </dd>
            <dt>Teléfono</dt>
            <dd>{{ c.telefono }}</dd>
            <dt>E-mail</dt>
            <dd>{{ c.email }}</dd>
          </dl>
          <dl class="datos">
            <dt>Oficina gestora</dt>
            <dd>{{ c.oficinaGestora }}</dd>
            <dt>Gestor</dt>
            <dd>{{ c.gestorAsignado }}</dd>
            <dt>Posición bancaria</dt>
            <dd>{{ c.posicionBancaria ?? '—' }}</dd>
          </dl>
          <div>
            <h3>Alertas ({{ c.alertas.length }})</h3>
            @for (a of c.alertas; track $index) {
              <div class="alerta" style="margin-bottom:.3rem">
                <strong>{{ a.tipo }}</strong> · {{ a.texto }}
                <span class="muted">{{ a.fecha | date: 'dd/MM/yyyy' }}</span>
              </div>
            } @empty {
              <span class="muted">Sin alertas</span>
            }
            <h3 style="margin-top:.75rem">Familia</h3>
            @for (m of c.familia; track m.clienteId) {
              <a [routerLink]="['/clientes', m.clienteId]" class="chip"
                >{{ m.nombre }} ({{ m.parentesco }})</a
              >&nbsp;
            } @empty {
              <span class="muted">Sin unidad familiar</span>
            }
          </div>
        </div>
        @if (llamadaId()) {
          <p class="alerta">Llamada registrada en el centro de comunicaciones: {{ llamadaId() }}</p>
        }
      </section>

      <section class="card">
        <div class="tabs">
          <button [class.activa]="pestana() === 'productos'" (click)="pestana.set('productos')">
            Productos ({{ polizas().length }})
          </button>
          <button [class.activa]="pestana() === 'recibos'" (click)="pestana.set('recibos')">
            Recibos ({{ recibos().length }})
          </button>
          <button
            [class.activa]="pestana() === 'prestaciones'"
            (click)="pestana.set('prestaciones')"
          >
            Prestaciones ({{ prestaciones().length }})
          </button>
          <button
            [class.activa]="pestana() === 'presupuestos'"
            (click)="pestana.set('presupuestos')"
          >
            Ppto. / Oportunidades ({{ presupuestos().length + oportunidades().length }})
          </button>
          @if (store.puede(V.GESTIONES_SGC30)) {
            <button [class.activa]="pestana() === 'gestiones'" (click)="pestana.set('gestiones')">
              Gestiones SGC 3.0 ({{ gestiones().length }})
            </button>
          }
          <button [class.activa]="pestana() === 'sgo'" (click)="pestana.set('sgo')">
            SGO ({{ sgo().length }})
          </button>
        </div>

        @switch (pestana()) {
          @case ('productos') {
            <div class="row" style="margin-bottom:.75rem">
              <label
                ><span>Ver</span>
                <select [ngModel]="filtroEstado()" (ngModelChange)="filtroEstado.set($event)">
                  <option value="EN_VIGOR">Productos en vigor</option>
                  <option value="ANULADA">Productos anulados</option>
                  <option value="">Todos</option>
                </select>
              </label>
            </div>
            <div class="grid grid-3">
              @for (p of polizasFiltradas(); track p.numero) {
                <article class="card poliza" [class.anulada]="p.estado !== 'EN_VIGOR'">
                  <div class="row">
                    <strong>{{ ramo(p.ramo) }}</strong
                    ><span class="spacer"></span
                    ><span
                      class="chip"
                      [class.chip-ok]="p.estado === 'EN_VIGOR'"
                      [class.chip-error]="p.estado === 'ANULADA'"
                      >{{ p.estado }}</span
                    >
                  </div>
                  <div>{{ p.producto }}</div>
                  <div class="muted">{{ p.riesgo }}</div>
                  <div class="row">
                    <a [routerLink]="['/polizas', p.numero]">Póliza {{ p.numero }}</a
                    ><span class="spacer"></span
                    ><strong>{{ p.primaAnual | currency: 'EUR' }}</strong>
                  </div>
                  <div class="muted">
                    Vence {{ p.fechaVencimiento | date: 'dd/MM/yyyy' }} · {{ p.formaPago }}
                  </div>
                  <div class="row acciones">
                    @for (a of p.acciones; track a) {
                      <span class="chip">{{ a }}</span>
                    }
                    @if (lanzaderaDe(p); as l) {
                      <a
                        class="chip chip-rojo"
                        [href]="l.url"
                        target="_blank"
                        rel="noopener"
                        (click)="auditar('lanzadera:' + l.codigo)"
                        >↗ {{ l.destino }}</a
                      >
                    }
                  </div>
                </article>
              } @empty {
                <div class="vacio">Sin productos para el filtro seleccionado</div>
              }
            </div>
          }
          @case ('recibos') {
            <pgm-tabla-exportable
              titulo="Recibos"
              nombreFichero="recibos"
              [columnas]="colRecibos"
              [filas]="recibos()"
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
          @case ('presupuestos') {
            <pgm-tabla-exportable
              titulo="Presupuestos"
              nombreFichero="presupuestos"
              [columnas]="colPresupuestos"
              [filas]="presupuestos()"
            />
            <br />
            <pgm-tabla-exportable
              titulo="Oportunidades y vencimientos"
              nombreFichero="oportunidades"
              [columnas]="colOportunidades"
              [filas]="oportunidades()"
            />
          }
          @case ('gestiones') {
            <pgm-tabla-exportable
              titulo="Gestiones comerciales (SGC 3.0)"
              nombreFichero="gestiones"
              [columnas]="colGestiones"
              [filas]="gestiones()"
              [mensajeVacio]="errorGestiones() ?? 'Sin gestiones'"
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
      </section>

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
              <p class="alerta">Borrador guardado: {{ borradorId() }}</p>
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
    .poliza {
      display: grid;
      gap: 0.35rem;
    }
    .poliza.anulada {
      opacity: 0.7;
    }
    .acciones {
      margin-top: 0.4rem;
    }
  `,
})
export class FichaClientePageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
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
  readonly pestana = signal<Pestana>('productos');
  readonly filtroEstado = signal<string>('EN_VIGOR');
  readonly llamadaId = signal<string | null>(null);
  readonly polizasFiltradas = computed(() => {
    const f = this.filtroEstado();
    return this.polizas().filter(
      (p) => !f || (f === 'EN_VIGOR' ? p.estado === 'EN_VIGOR' : p.estado !== 'EN_VIGOR'),
    );
  });

  readonly dialogo = signal(false);
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
    { clave: 'estado', titulo: 'Estado' },
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
    { clave: 'estado', titulo: 'Estado' },
    { clave: 'fechaOcurrencia', titulo: 'Ocurrencia' },
    { clave: 'descripcion', titulo: 'Descripción' },
    { clave: 'tramitador', titulo: 'Tramitador' },
  ];
  readonly colPresupuestos: Columna<Presupuesto>[] = [
    { clave: 'numero', titulo: 'Presupuesto' },
    { clave: 'ramo', titulo: 'Ramo' },
    { clave: 'producto', titulo: 'Producto' },
    { clave: 'estado', titulo: 'Estado' },
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
    { clave: 'estado', titulo: 'Estado' },
    { clave: 'descripcion', titulo: 'Descripción' },
    { clave: 'gestor', titulo: 'Gestor' },
    { clave: 'origen', titulo: 'Origen' },
  ];
  readonly colSgo: Columna<SolicitudSgo>[] = [
    { clave: 'id', titulo: 'Solicitud' },
    { clave: 'tipo', titulo: 'Tipo' },
    { clave: 'estado', titulo: 'Estado' },
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
      this.pestana.set('productos');
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

  abrirDialogo(): void {
    this.formulario = {
      producto: '',
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
