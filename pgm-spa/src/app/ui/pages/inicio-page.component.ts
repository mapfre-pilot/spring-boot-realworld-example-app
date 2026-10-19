import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ClienteResumen, CriteriosBusqueda, Ramo } from '../../domain/models/api.models';
import { CarruselRamosComponent } from '../components/carrusel-ramos.component';
import { EstadoComponent } from '../components/estado.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/** /inicio — buscador multicriterio de clientes (documento, nombre, teléfono, e-mail, póliza, tarjeta sanitaria, localidad). */
@Component({
  selector: 'pgm-inicio-page',
  imports: [
    FormsModule,
    RouterLink,
    TablaExportableComponent,
    EstadoComponent,
    CarruselRamosComponent,
  ],
  template: `
    <section class="card">
      <h1>Buscar cliente</h1>
      <form class="grid grid-4" (ngSubmit)="buscar()">
        <label
          >Nombre / razón social
          <input name="texto" [(ngModel)]="criterios.texto" placeholder="Ej. García"
        /></label>
        <label
          >Documento (NIF/NIE/CIF) <input name="documento" [(ngModel)]="criterios.documento"
        /></label>
        <label>Teléfono <input name="telefono" [(ngModel)]="criterios.telefono" /></label>
        <label>E-mail <input name="email" [(ngModel)]="criterios.email" /></label>
        <label>Nº póliza <input name="poliza" [(ngModel)]="criterios.poliza" /></label>
        <label
          >Tarjeta sanitaria
          <input name="tarjetaSanitaria" [(ngModel)]="criterios.tarjetaSanitaria"
        /></label>
        <label>Localidad <input name="localidad" [(ngModel)]="criterios.localidad" /></label>
        <div class="row" style="align-items:flex-end">
          <button class="btn" type="submit" [disabled]="cargando()">Buscar</button>
          <button class="btn btn-secundario" type="button" (click)="limpiar()">Limpiar</button>
        </div>
      </form>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
    </section>

    @if (resultados() !== null) {
      <section class="card">
        <pgm-tabla-exportable
          titulo="Resultados"
          nombreFichero="clientes"
          [columnas]="columnas"
          [filas]="resultados()!"
          mensajeVacio="Ningún cliente cumple los criterios"
        />
        @if (resultados()!.length) {
          <p class="muted">
            Abrir ficha:
            @for (c of resultados(); track c.id) {
              <a [routerLink]="['/clientes', c.id]" class="chip">{{ c.nombre }} {{ c.apellidos }}</a
              >&nbsp;
            }
          </p>
        }
      </section>
    }

    <section class="card">
      <h2>Acceso rápido por ramo</h2>
      <pgm-carrusel-ramos (seleccion)="irARamo($event)" />
    </section>
  `,
})
export class InicioPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  private readonly router = inject(Router);
  criterios: CriteriosBusqueda = {};
  readonly resultados = signal<ClienteResumen[] | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly columnas: Columna<ClienteResumen>[] = [
    { clave: 'documento', titulo: 'Documento' },
    { clave: 'nombre', titulo: 'Nombre' },
    { clave: 'apellidos', titulo: 'Apellidos' },
    { clave: 'tipologia', titulo: 'Tipología' },
    { clave: 'estado', titulo: 'Estado' },
    { clave: 'localidad', titulo: 'Localidad' },
    { clave: 'telefono', titulo: 'Teléfono' },
    { clave: 'numeroPolizasEnVigor', titulo: 'Pólizas en vigor' },
  ];

  async buscar(): Promise<void> {
    this.cargando.set(true);
    this.error.set(null);
    try {
      const r = await firstValueFrom(this.repo.buscarClientes(this.criterios));
      this.resultados.set(r.items);
      if (r.items.length === 1) void this.router.navigate(['/clientes', r.items[0].id]);
    } catch (e) {
      this.error.set((e as Error).message);
      this.resultados.set(null);
    } finally {
      this.cargando.set(false);
    }
  }

  limpiar(): void {
    this.criterios = {};
    this.resultados.set(null);
    this.error.set(null);
  }

  irARamo(ramo: Ramo): void {
    void this.router.navigate(['/nueva-produccion'], { queryParams: { ramo } });
  }
}
