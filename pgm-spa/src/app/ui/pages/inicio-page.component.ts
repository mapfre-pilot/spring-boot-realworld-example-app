import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { ClienteResumen, CriteriosBusqueda, Lanzadera } from '../../domain/models/api.models';
import { EstadoComponent } from '../components/estado.component';
import { IconoComponent } from '../components/icono.component';
import { ETIQUETA_ESTADO } from '../components/indicadores-cliente.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/** /inicio — «Buscador de clientes» de PGM: 13 criterios con su matriz de compatibilidad y validaciones literales, grid de resultados y enlaces de interés. */
@Component({
  selector: 'pgm-inicio-page',
  imports: [FormsModule, TablaExportableComponent, EstadoComponent, IconoComponent],
  template: `
    @if (resultados() === null) {
      <section class="card buscador">
        <h2 class="titulo-seccion">Buscador de clientes</h2>
        <form (ngSubmit)="buscar()">
          <div class="campos">
            @for (c of CAMPOS; track c.clave) {
              <label [class]="c.ancho">
                {{ c.etiqueta }}
                <input
                  [name]="c.clave"
                  [(ngModel)]="criterios[c.clave]"
                  [disabled]="deshabilitado(c.clave)"
                  [attr.aria-invalid]="!!erroresCampo()[c.clave]"
                  (ngModelChange)="erroresCampo.set({})"
                />
                @if (erroresCampo()[c.clave]; as msg) {
                  <small class="error-campo">{{ msg }}</small>
                }
              </label>
            }
          </div>
          <div class="pie">
            <a class="btn-enlace" href="#" (click)="$event.preventDefault()"
              >Ficha Ampliada de Cliente</a
            >
            @if (store.nuuma()) {
              <a class="btn-enlace" href="#" (click)="$event.preventDefault()">Bandeja SGO</a>
            }
            <span class="spacer"></span>
            <button class="btn btn-secundario" type="button" (click)="limpiar()">LIMPIAR</button>
            <button class="btn" type="submit" [disabled]="cargando() || !sePuedeBuscar()">
              <pgm-icono nombre="buscar" [trazo]="2.4" /> BUSCAR
            </button>
          </div>
        </form>
        <pgm-estado [cargando]="cargando()" [error]="error()" />
      </section>
    } @else {
      <div class="row">
        <h2 class="titulo-seccion" style="margin:0">Resultados de búsqueda</h2>
        <span class="spacer"></span>
        <button class="btn-enlace nueva" type="button" (click)="limpiar()">
          <pgm-icono nombre="buscar" /> Nueva búsqueda
        </button>
      </div>
      <section class="card">
        <pgm-tabla-exportable
          titulo="Todos los resultados"
          nombreFichero="clientes"
          [columnas]="columnas"
          [filas]="resultados()!"
          [navegable]="true"
          (filaSeleccionada)="abrir($event)"
          mensajeVacio="No hay resultados para los criterios introducidos"
        />
        @if (resultados()?.length === 0) {
          <div class="row" style="margin-top:.5rem">
            <span class="muted">¿No encuentras al cliente?</span>
            <a class="btn-enlace" href="#" (click)="$event.preventDefault()">Alta cliente</a>
          </div>
        }
      </section>
    }

    @if (enlaces().length) {
      <section class="enlaces">
        <h2>Enlaces de interés</h2>
        <div class="tiles">
          @for (l of enlaces(); track l.codigo) {
            @if (l.requiereNuuma && !store.nuuma()) {
              <div class="tile deshabilitado" title="Requiere estructura comercial (NUUMA)">
                <pgm-icono nombre="externo" [tam]="26" [trazo]="1.4" />
                <strong>{{ l.nombre }}</strong>
                <small>Requiere NUUMA</small>
              </div>
            } @else {
              <a class="tile" [href]="l.url" target="_blank" rel="noopener">
                <pgm-icono nombre="externo" [tam]="26" [trazo]="1.4" />
                <strong>{{ l.nombre }}</strong>
              </a>
            }
          }
        </div>
      </section>
    }
  `,
  styles: `
    .error-campo {
      color: var(--rojo, #c00);
      font-size: 0.75rem;
    }
    .buscador {
      max-width: 1080px;
      width: 100%;
      margin: 0 auto;
    }
    .campos {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 1rem 1.25rem;
    }
    .c2 {
      grid-column: span 2;
    }
    .pie {
      display: flex;
      align-items: center;
      gap: 1rem;
      margin-top: 1.5rem;
    }
    .pie .btn {
      min-width: 160px;
    }
    .nueva {
      color: var(--pgm-texto-2);
    }
    .enlaces {
      max-width: 1080px;
      width: 100%;
      margin: 0 auto;
      background: var(--pgm-fondo-franja);
      border: 1px solid var(--pgm-borde);
      padding: 1.5rem;
    }
    .tiles {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 1rem;
    }
    .tile {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 0.5rem;
      padding: 1.25rem 0.75rem;
      background: #fff;
      border: 1px solid var(--pgm-borde-input);
      color: var(--pgm-rojo);
      text-align: center;
    }
    .tile strong {
      color: var(--pgm-texto);
      font-size: 1rem;
    }
    .tile:hover {
      text-decoration: none;
      border-color: var(--pgm-rojo);
    }
    .tile.deshabilitado {
      color: var(--pgm-gris-3);
    }
    @media (max-width: 900px) {
      .campos {
        grid-template-columns: 1fr 1fr;
      }
    }
  `,
})
export class InicioPageComponent implements OnInit {
  private readonly repo = inject(PGM_REPOSITORY);
  private readonly router = inject(Router);
  readonly store = inject(ContextoStore);
  criterios: Record<keyof CriteriosBusqueda, string> = {} as Record<
    keyof CriteriosBusqueda,
    string
  >;
  readonly erroresCampo = signal<Partial<Record<keyof CriteriosBusqueda, string>>>({});
  /** Los 13 criterios del buscador de PGM, en su orden. */
  readonly CAMPOS: { clave: keyof CriteriosBusqueda; etiqueta: string; ancho: string }[] = [
    { clave: 'documento', etiqueta: 'Documento', ancho: 'c1' },
    { clave: 'texto', etiqueta: 'Nombre/Razón social', ancho: 'c2' },
    { clave: 'primerApellido', etiqueta: 'Primer Apellido', ancho: 'c1' },
    { clave: 'segundoApellido', etiqueta: 'Segundo apellido', ancho: 'c1' },
    { clave: 'codigoPostal', etiqueta: 'Código Postal', ancho: 'c1' },
    { clave: 'email', etiqueta: 'Correo Electrónico', ancho: 'c2' },
    { clave: 'telefono', etiqueta: 'Teléfono', ancho: 'c1' },
    { clave: 'expediente', etiqueta: 'Nº Expediente', ancho: 'c1' },
    { clave: 'matricula', etiqueta: 'Matrícula', ancho: 'c1' },
    { clave: 'poliza', etiqueta: 'Nº póliza', ancho: 'c1' },
    { clave: 'presupuesto', etiqueta: 'Nº presupuesto', ancho: 'c1' },
    { clave: 'recibo', etiqueta: 'Nº recibo', ancho: 'c1' },
    { clave: 'tarjetaSanitaria', etiqueta: 'Nº tarjeta sanitaria', ancho: 'c1' },
  ];
  /** Matriz de compatibilidad de PGM_FormularioBusqueda_Cliente: Documento y Nombre deshabilitan el resto de criterios. */
  private static readonly INCOMPATIBLES: Partial<
    Record<keyof CriteriosBusqueda, (keyof CriteriosBusqueda)[]>
  > = {
    documento: [
      'texto',
      'primerApellido',
      'segundoApellido',
      'email',
      'telefono',
      'expediente',
      'matricula',
      'poliza',
      'recibo',
      'tarjetaSanitaria',
    ],
    texto: [
      'documento',
      'expediente',
      'matricula',
      'poliza',
      'presupuesto',
      'recibo',
      'tarjetaSanitaria',
    ],
  };
  /** Enlaces de interés de PGM_Avisos_y_Novedades_Inicio (sin parámetros de cliente). */
  readonly ENLACES_INTERES = [
    {
      codigo: 'competencia',
      nombre: 'Gestor de la Competencia',
      url: 'https://internos.mapfre.com/gestorcompetencia/',
    },
    {
      codigo: 'productos',
      nombre: 'Guía de productos',
      url: 'https://www.mapfre.es/informacion-de-interes/',
    },
    {
      codigo: 'gestor-cliente',
      nombre: 'Gestor del cliente',
      url: 'https://internos.mapfre.com/gestorcompetencia/home-cliente/',
    },
    {
      codigo: 'talleres',
      nombre: 'Buscador de talleres',
      url: 'https://www.mapfre.es/seguros/Buscador.do?buscadores=oficinas,talleres,centrosMedicos,veterinarios&activo=talleres',
    },
    { codigo: 'medallia', nombre: 'Medallia', url: 'https://mapfre.medallia.eu/sso/mapfre/' },
    { codigo: 'stories', nombre: '#MAPFREStories', url: 'https://www.mapfrestories.com' },
  ];
  readonly resultados = signal<ClienteResumen[] | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly enlaces = computed(() => [
    ...this.ENLACES_INTERES.map((e) => ({ ...e, requiereNuuma: false })),
    ...this.lanzaderas().filter((l) => !l.ramo),
  ]);
  readonly columnas: Columna<ClienteResumen>[] = [
    {
      clave: 'nombre',
      titulo: 'Nombre/Razón social',
      formato: (_, f) => `${f.nombre} ${f.apellidos}`.toUpperCase(),
    },
    { clave: 'documento', titulo: 'Documento' },
    {
      clave: 'fechaNacimiento',
      titulo: 'Fecha de nacimiento',
      formato: (v) => (v ? new Date(`${v}`).toLocaleDateString('es-ES') : '-'),
    },
    { clave: 'domicilio', titulo: 'Domicilio habitual', formato: (v) => `${v ?? '-'}` },
    { clave: 'codigoPostal', titulo: 'Código postal', formato: (v) => `${v ?? '-'}` },
    {
      clave: 'estado',
      titulo: 'Estado',
      formato: (v) => ETIQUETA_ESTADO[v as ClienteResumen['estado']] ?? `${v}`,
      etiqueta: (v) =>
        'pill-estado' + (v === 'POTENCIAL' ? ' potencial' : v === 'ANULADO' ? ' anulado' : ''),
    },
    { clave: 'robinson', titulo: 'Robinson', formato: (v) => (v ? 'Robinson' : '') },
  ];

  deshabilitado(clave: keyof CriteriosBusqueda): boolean {
    return Object.entries(InicioPageComponent.INCOMPATIBLES).some(
      ([origen, bloqueados]) =>
        origen !== clave &&
        !!this.criterios[origen as keyof CriteriosBusqueda]?.trim() &&
        bloqueados.includes(clave),
    );
  }

  sePuedeBuscar(): boolean {
    return Object.values(this.criterios).some((v) => !!v?.trim());
  }

  /** Validaciones de PGM_EsValidaBusquedaCliente con sus textos literales (el BFF las repite). */
  private validar(): boolean {
    const c = this.criterios;
    const e: Partial<Record<keyof CriteriosBusqueda, string>> = {};
    const nombre = c.texto?.trim() ?? '';
    const ap1 = c.primerApellido?.trim() ?? '';
    const ap2 = c.segundoApellido?.trim() ?? '';
    if (nombre && nombre.length < 2) e.texto = 'El nombre debe contener al menos 2 caracteres';
    if (ap1 && ap1.length < 2) e.primerApellido = 'El apellido debe contener al menos 2 caracteres';
    if (ap2 && ap2.length < 2)
      e.segundoApellido = 'El apellido debe contener al menos 2 caracteres';
    if (ap1 && !nombre && !ap2)
      e.texto = 'Es necesario cumplimentar también el nombre o el segundo apellido';
    if (ap2 && !nombre && !ap1)
      e.texto = 'Es necesario cumplimentar también el nombre o el primer apellido';
    if (c.email?.trim() && !/^[\w.+-]+@[\w-]+(\.[\w-]+)+$/.test(c.email.trim()))
      e.email = 'Email no válido';
    if (c.telefono?.trim() && !/^\+?\d{9,15}$/.test(c.telefono.replace(/[\s-]/g, '')))
      e.telefono = 'Formato de número de teléfono inválido';
    if (c.poliza?.trim() && !/^[A-Za-z0-9/-]{4,20}$/.test(c.poliza.trim()))
      e.poliza = 'Formato de número de póliza inválido';
    this.erroresCampo.set(e);
    return Object.keys(e).length === 0;
  }

  async ngOnInit(): Promise<void> {
    try {
      this.lanzaderas.set((await firstValueFrom(this.repo.lanzaderas())).items);
    } catch {
      this.lanzaderas.set([]);
    }
  }

  async buscar(): Promise<void> {
    if (!this.sePuedeBuscar() || !this.validar()) return;
    this.cargando.set(true);
    this.error.set(null);
    try {
      const r = await firstValueFrom(this.repo.buscarClientes(this.criterios));
      if (r.items.length === 1) {
        void this.router.navigate(['/clientes', r.items[0].id]);
        return;
      }
      this.resultados.set(r.items);
    } catch (e) {
      this.error.set((e as Error).message);
      this.resultados.set(null);
    } finally {
      this.cargando.set(false);
    }
  }

  abrir(c: ClienteResumen): void {
    void this.router.navigate(['/clientes', c.id]);
  }

  limpiar(): void {
    this.criterios = {} as Record<keyof CriteriosBusqueda, string>;
    this.erroresCampo.set({});
    this.resultados.set(null);
    this.error.set(null);
  }
}
