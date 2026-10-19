import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { ClienteResumen, GestionComercial, Oportunidad, Visibilidad } from '../../domain/models/api.models';
import { EstadoComponent } from '../components/estado.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/**
 * /gestion-comercial — Vencimientos, Actividad comercial y Gestiones SGC 3.0.
 * Reproduce la degradación observada en Appian: el grupo (PGM_AsesorComercial) da acceso a la página,
 * pero Gestiones/Actividad/Añadir vencimiento exigen además perfil SGC 3.0 y estructura comercial (NUUMA).
 */
@Component({
  selector: 'pgm-gestion-comercial-page',
  imports: [FormsModule, RouterLink, EstadoComponent, TablaExportableComponent],
  template: `
    <section class="card">
      <div class="row">
        <h1>Gestión comercial</h1>
        <span class="spacer"></span>
        <span class="chip" [class.chip-ok]="store.contexto()?.perfilSgc30" [class.chip-aviso]="!store.contexto()?.perfilSgc30">Perfil SGC 3.0: {{ store.contexto()?.perfilSgc30 ?? 'sin perfil' }}</span>
        <span class="chip" [class.chip-ok]="store.nuuma()" [class.chip-aviso]="!store.nuuma()">NUUMA: {{ store.nuuma() ?? 'sin estructura' }}</span>
      </div>
      @if (!store.puede(V.GESTIONES_SGC30)) {
        <div class="alerta">Tu usuario no tiene perfil comercial completo (perfil SGC 3.0 + estructura comercial). <strong>Gestiones</strong>, <strong>Actividad comercial</strong> y <strong>Añadir vencimiento</strong> no están disponibles; sí puedes consultar vencimientos.</div>
      }
      <form class="row" (ngSubmit)="buscar()">
        <label>Cliente (nombre o documento) <input name="q" [(ngModel)]="q" /></label>
        <button class="btn" type="submit" style="align-self:flex-end">Buscar</button>
        @if (store.puede(V.ANADIR_VENCIMIENTO)) { <button class="btn btn-secundario" type="button" style="align-self:flex-end" [disabled]="!cliente()" [routerLink]="cliente() ? ['/clientes', cliente()!.id] : null">Añadir vencimiento (ficha)</button> }
      </form>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
      @if (candidatos().length > 1) {
        <p>@for (c of candidatos(); track c.id) { <button class="chip" (click)="seleccionar(c)">{{ c.nombre }} {{ c.apellidos }} · {{ c.documento }}</button>&nbsp; }</p>
      }
    </section>

    @if (cliente(); as c) {
      <section class="card">
        <div class="row"><h2>{{ c.nombre }} {{ c.apellidos }}</h2><a [routerLink]="['/clientes', c.id]">Ficha 360</a></div>
        <div class="tabs">
          <button [class.activa]="pestana() === 'vencimientos'" (click)="pestana.set('vencimientos')">Vencimientos ({{ vencimientos().length }})</button>
          @if (store.puede(V.ACTIVIDAD_COMERCIAL)) { <button [class.activa]="pestana() === 'actividad'" (click)="pestana.set('actividad')">Actividad comercial ({{ actividad().length }})</button> }
          @if (store.puede(V.GESTIONES_SGC30)) { <button [class.activa]="pestana() === 'gestiones'" (click)="pestana.set('gestiones')">Gestiones ({{ gestiones().length }})</button> }
        </div>
        @switch (pestana()) {
          @case ('vencimientos') { <pgm-tabla-exportable titulo="Vencimientos y oportunidades" nombreFichero="vencimientos" [columnas]="colVenc" [filas]="vencimientos()" mensajeVacio="Sin vencimientos (0 elementos)" /> }
          @case ('actividad') { <pgm-tabla-exportable titulo="Actividad comercial" nombreFichero="actividad" [columnas]="colGest" [filas]="actividad()" /> }
          @case ('gestiones') { <pgm-tabla-exportable titulo="Gestiones SGC 3.0" nombreFichero="gestiones" [columnas]="colGest" [filas]="gestiones()" /> }
        }
      </section>
    }
  `,
})
export class GestionComercialPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  readonly store = inject(ContextoStore);
  readonly V = Visibilidad;
  q = '';
  readonly candidatos = signal<ClienteResumen[]>([]);
  readonly cliente = signal<ClienteResumen | null>(null);
  readonly vencimientos = signal<Oportunidad[]>([]);
  readonly gestiones = signal<GestionComercial[]>([]);
  readonly actividad = signal<GestionComercial[]>([]);
  readonly pestana = signal<'vencimientos' | 'actividad' | 'gestiones'>('vencimientos');
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly colVenc: Columna<Oportunidad>[] = [
    { clave: 'tipo', titulo: 'Tipo' }, { clave: 'ramo', titulo: 'Ramo' }, { clave: 'polizaNumero', titulo: 'Póliza' }, { clave: 'fecha', titulo: 'Fecha' }, { clave: 'prioridad', titulo: 'Prioridad' }, { clave: 'descripcion', titulo: 'Descripción' },
  ];
  readonly colGest: Columna<GestionComercial>[] = [
    { clave: 'fecha', titulo: 'Fecha' }, { clave: 'tipo', titulo: 'Tipo' }, { clave: 'estado', titulo: 'Estado' }, { clave: 'descripcion', titulo: 'Descripción' }, { clave: 'gestor', titulo: 'Gestor' }, { clave: 'origen', titulo: 'Origen' },
  ];

  async buscar(): Promise<void> {
    this.cargando.set(true); this.error.set(null); this.cliente.set(null); this.candidatos.set([]);
    try {
      const r = await firstValueFrom(this.repo.buscarClientes(/^[0-9A-Z]{8,9}$/i.test(this.q.trim()) ? { documento: this.q.trim() } : { texto: this.q.trim() }));
      this.candidatos.set(r.items);
      if (r.items.length === 1) await this.seleccionar(r.items[0]);
      if (!r.items.length) this.error.set('Ningún cliente cumple los criterios');
    } catch (e) {
      this.error.set((e as Error).message);
    } finally {
      this.cargando.set(false);
    }
  }

  async seleccionar(c: ClienteResumen): Promise<void> {
    this.cliente.set(c); this.pestana.set('vencimientos');
    this.vencimientos.set((await firstValueFrom(this.repo.oportunidades(c.id))).items);
    if (this.store.puede(Visibilidad.GESTIONES_SGC30)) {
      const g = (await firstValueFrom(this.repo.gestiones(c.id))).items;
      this.gestiones.set(g);
      this.actividad.set(g.filter((x) => x.origen !== 'SGC'));
    }
  }
}
