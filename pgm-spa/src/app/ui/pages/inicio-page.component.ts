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

/** /inicio — buscador multicriterio de clientes (documento, nombre, teléfono, e-mail, póliza, tarjeta sanitaria, localidad). */
@Component({
  selector: 'pgm-inicio-page',
  imports: [FormsModule, TablaExportableComponent, EstadoComponent, IconoComponent],
  template: `
    @if (resultados() === null) {
      <section class="card buscador">
        <h2 class="titulo-seccion">Buscador de clientes</h2>
        <form (ngSubmit)="buscar()">
          <div class="campos">
            <label class="c1"
              >Documento <input name="documento" [(ngModel)]="criterios.documento"
            /></label>
            <label class="c2"
              >Nombre/Razón social <input name="texto" [(ngModel)]="criterios.texto"
            /></label>
            <label class="c1"
              >Teléfono <input name="telefono" [(ngModel)]="criterios.telefono"
            /></label>
            <label class="c2"
              >Correo electrónico <input name="email" [(ngModel)]="criterios.email"
            /></label>
            <label class="c1"
              >Nº póliza <input name="poliza" [(ngModel)]="criterios.poliza"
            /></label>
            <label class="c1"
              >Nº tarjeta sanitaria
              <input name="tarjetaSanitaria" [(ngModel)]="criterios.tarjetaSanitaria"
            /></label>
            <label class="c1"
              >Localidad <input name="localidad" [(ngModel)]="criterios.localidad"
            /></label>
          </div>
          <div class="pie">
            <span class="muted"
              >Introduce al menos un criterio. Con un único resultado se abre la ficha
              directamente.</span
            >
            <span class="spacer"></span>
            <button class="btn btn-secundario" type="button" (click)="limpiar()">Limpiar</button>
            <button class="btn" type="submit" [disabled]="cargando()">
              <pgm-icono nombre="buscar" [trazo]="2.4" /> Buscar
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
          mensajeVacio="Ningún cliente cumple los criterios de búsqueda"
        />
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
  criterios: CriteriosBusqueda = {};
  readonly resultados = signal<ClienteResumen[] | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly lanzaderas = signal<Lanzadera[]>([]);
  readonly enlaces = computed(() => this.lanzaderas().filter((l) => !l.ramo));
  readonly columnas: Columna<ClienteResumen>[] = [
    {
      clave: 'nombre',
      titulo: 'Nombre/Razón social',
      formato: (_, f) => `${f.nombre} ${f.apellidos}`.toUpperCase(),
    },
    { clave: 'documento', titulo: 'Documento' },
    {
      clave: 'tipologia',
      titulo: 'Tipología',
      formato: (v) => `${v}`.charAt(0) + `${v}`.slice(1).toLowerCase(),
    },
    { clave: 'localidad', titulo: 'Localidad' },
    { clave: 'telefono', titulo: 'Teléfono' },
    { clave: 'numeroPolizasEnVigor', titulo: 'Pólizas en vigor' },
    {
      clave: 'estado',
      titulo: 'Estado',
      formato: (v) => ETIQUETA_ESTADO[v as ClienteResumen['estado']] ?? `${v}`,
      etiqueta: (v) =>
        'pill-estado' + (v === 'POTENCIAL' ? ' potencial' : v === 'ANULADO' ? ' anulado' : ''),
    },
  ];

  async ngOnInit(): Promise<void> {
    try {
      this.lanzaderas.set((await firstValueFrom(this.repo.lanzaderas())).items);
    } catch {
      this.lanzaderas.set([]);
    }
  }

  async buscar(): Promise<void> {
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
    this.criterios = {};
    this.resultados.set(null);
    this.error.set(null);
  }
}
