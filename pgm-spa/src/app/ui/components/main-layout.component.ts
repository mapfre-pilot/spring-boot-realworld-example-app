import { Component, OnInit, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Visibilidad, VisibilidadKey } from '../../domain/models/api.models';
import { AuthService } from '../../infrastructure/auth/auth.service';

interface Entrada {
  ruta: string;
  texto: string;
  clave: VisibilidadKey;
}

@Component({
  selector: 'pgm-main-layout',
  imports: [RouterOutlet, RouterLink, RouterLinkActive],
  template: `
    <header class="cabecera">
      <a routerLink="/inicio" class="marca">PGM <span>Posición Global MAPFRE</span></a>
      <nav>
        @for (e of entradas; track e.ruta) {
          @if (store.puede(e.clave)) {
            <a [routerLink]="e.ruta" routerLinkActive="activa">{{ e.texto }}</a>
          }
        }
      </nav>
      <div class="usuario">
        @if (store.cargado()) {
          <strong>{{ store.nombre() }}</strong>
          <small class="muted">
            {{ store.contexto()?.perfilSgc30 ?? 'sin perfil SGC 3.0' }}
            · NUUMA {{ store.nuuma() ?? '—' }}
          </small>
        }
        @if (auth.habilitado) {
          <button class="btn-enlace" (click)="auth.logout()">Salir</button>
        } @else {
          <span class="chip">perfil local</span>
        }
      </div>
    </header>
    <main>
      @if (store.error()) {
        <div class="alerta alerta-error">
          No se ha podido cargar el contexto de usuario desde el BFF: {{ store.error() }}
          <button class="btn-enlace" (click)="store.cargar()">Reintentar</button>
        </div>
      }
      <router-outlet />
    </main>
  `,
  styles: `
    .cabecera { display: flex; align-items: center; gap: 1.5rem; padding: 0 1.25rem; height: 56px; background: var(--pgm-rojo); color: #fff; position: sticky; top: 0; z-index: 10; }
    .marca { color: #fff; font-weight: 700; font-size: 1.2rem; white-space: nowrap; }
    .marca span { font-weight: 400; font-size: .8rem; margin-left: .4rem; opacity: .9; }
    nav { display: flex; gap: .25rem; flex: 1; flex-wrap: wrap; }
    nav a { color: #fff; padding: .4rem .7rem; border-radius: 4px; opacity: .9; }
    nav a:hover, nav a.activa { background: rgba(255,255,255,.18); opacity: 1; text-decoration: none; }
    .usuario { display: flex; flex-direction: column; align-items: flex-end; line-height: 1.2; }
    .usuario .muted, .usuario .btn-enlace { color: #fff; opacity: .85; font-size: .75rem; }
    main { padding: 1.25rem; max-width: 1400px; margin: 0 auto; display: grid; gap: 1rem; }
  `,
})
export class MainLayoutComponent implements OnInit {
  readonly store = inject(ContextoStore);
  readonly auth = inject(AuthService);
  readonly entradas: Entrada[] = [
    { ruta: '/inicio', texto: 'Inicio', clave: Visibilidad.INICIO },
    { ruta: '/nueva-produccion', texto: 'N. Producción', clave: Visibilidad.NUEVA_PRODUCCION },
    { ruta: '/gestion-cartera', texto: 'Gestión de cartera', clave: Visibilidad.GESTION_CARTERA },
    { ruta: '/prestaciones', texto: 'Prestaciones', clave: Visibilidad.PRESTACIONES },
    { ruta: '/recibos', texto: 'Recibos', clave: Visibilidad.RECIBOS },
    { ruta: '/gestion-comercial', texto: 'Gestión comercial', clave: Visibilidad.GESTION_COMERCIAL },
    { ruta: '/utilidades', texto: 'Utilidades', clave: Visibilidad.UTILIDADES },
    { ruta: '/cuadro-mando', texto: 'Cuadro de mando', clave: Visibilidad.CUADRO_MANDO },
  ];

  ngOnInit(): void {
    if (!this.store.cargado()) void this.store.cargar();
  }
}
