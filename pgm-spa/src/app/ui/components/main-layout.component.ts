import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { ContextoStore } from '../../application/use-cases/contexto.store';
import { Visibilidad, VisibilidadKey } from '../../domain/models/api.models';
import { AuthService } from '../../infrastructure/auth/auth.service';
import { environment } from '../../../environments/environment';
import { IconoComponent } from './icono.component';
import { MenuLanzaderasComponent } from './menu-lanzaderas.component';

interface Entrada {
  ruta: string;
  texto: string;
  /** Se abre como pop-up de accesos por ramo (como las tarjetas de PGM en Appian) en vez de navegar. */
  popup?: boolean;
  clave: VisibilidadKey;
}

/** Marco de la aplicación: franja de entorno, cabecera MAPFRE con menú filtrado por las visibilidades del BFF y usuario. */
@Component({
  selector: 'pgm-main-layout',
  imports: [RouterOutlet, RouterLink, RouterLinkActive, IconoComponent, MenuLanzaderasComponent],
  template: `
    @if (entorno) {
      <div class="franja-entorno">{{ entorno }}</div>
    }
    <header class="cabecera">
      <a routerLink="/inicio" class="marca" aria-label="PGM · Inicio">
        <span class="logo">mapfre</span><span class="app">PGM</span>
      </a>
      <nav aria-label="Menú principal">
        @for (e of entradas; track e.ruta) {
          @if (store.puede(e.clave)) {
            @if (e.popup) {
              <button
                type="button"
                class="nav-popup"
                [class.activa]="popup()?.ruta === e.ruta"
                [attr.aria-expanded]="popup()?.ruta === e.ruta"
                (click)="popup.set(popup()?.ruta === e.ruta ? null : e)"
              >
                {{ e.texto }}
              </button>
            } @else {
              <a [routerLink]="e.ruta" routerLinkActive="activa">{{ e.texto }}</a>
            }
          }
        }
      </nav>
      @if (popup(); as p) {
        <pgm-menu-lanzaderas [titulo]="p.texto" [ruta]="p.ruta" (cerrar)="popup.set(null)" />
      }
      <div class="usuario">
        <button
          class="avatar"
          type="button"
          [attr.aria-expanded]="menu()"
          aria-label="Usuario"
          (click)="menu.set(!menu())"
        >
          {{ iniciales() }}
        </button>
        @if (menu()) {
          <div class="menu-usuario" role="menu">
            <strong>{{ store.nombre() }}</strong>
            <span class="muted">Perfil SGC 3.0: {{ store.contexto()?.perfilSgc30 ?? '—' }}</span>
            <span class="muted">NUUMA: {{ store.nuuma() ?? '—' }}</span>
            @if (auth.activo()) {
              <button class="btn-enlace" type="button" (click)="auth.logout()">
                <pgm-icono nombre="salir" [tam]="16" /> Cerrar sesión
              </button>
            } @else {
              <span class="chip">perfil local (sin Entra ID)</span>
            }
          </div>
        }
      </div>
    </header>
    <main>
      @if (store.error()) {
        <div class="alerta alerta-error">
          <pgm-icono nombre="aviso" />
          No se ha podido cargar el contexto de usuario desde el BFF: {{ store.error() }}
          <button class="btn-enlace" (click)="store.cargar()">Reintentar</button>
        </div>
      }
      <router-outlet />
    </main>
  `,
  styles: `
    .franja-entorno {
      background: var(--pgm-azul-entorno);
      color: #fff;
      text-align: center;
      font-size: 0.9rem;
      padding: 0.3rem;
    }
    .cabecera {
      display: flex;
      align-items: center;
      gap: 2rem;
      padding: 0 1.5rem;
      height: 64px;
      background: #fff;
      border-bottom: 1px solid var(--pgm-borde);
      position: sticky;
      top: 0;
      z-index: 10;
    }
    .marca {
      display: flex;
      align-items: baseline;
      gap: 0.5rem;
      white-space: nowrap;
      text-decoration: none;
    }
    .logo {
      color: var(--pgm-rojo);
      font-weight: 800;
      font-size: 1.6rem;
      letter-spacing: -0.02em;
    }
    .app {
      color: var(--pgm-texto-2);
      font-weight: 600;
      font-size: 0.85rem;
      border-left: 1px solid var(--pgm-borde-input);
      padding-left: 0.5rem;
    }
    nav {
      display: flex;
      gap: 1.6rem;
      flex: 1;
      flex-wrap: wrap;
      height: 100%;
    }
    nav .nav-popup {
      border: 0;
      background: none;
      cursor: pointer;
      font: inherit;
    }
    nav a,
    nav .nav-popup {
      display: flex;
      align-items: center;
      color: #333;
      text-transform: uppercase;
      font-size: 0.92rem;
      border-bottom: 3px solid transparent;
      border-top: 3px solid transparent;
    }
    nav a:hover,
    nav .nav-popup:hover {
      text-decoration: none;
      border-bottom-color: var(--pgm-borde-input);
    }
    nav a.activa,
    nav .nav-popup.activa {
      font-weight: 600;
      color: #111;
      border-bottom-color: #b8bcc0;
    }
    .usuario {
      position: relative;
    }
    .avatar {
      width: 38px;
      height: 38px;
      border-radius: 50%;
      border: 1px solid var(--pgm-borde-input);
      background: #fff;
      font: inherit;
      font-weight: 600;
      cursor: pointer;
    }
    .menu-usuario {
      position: absolute;
      right: 0;
      top: 46px;
      min-width: 240px;
      display: grid;
      gap: 0.35rem;
      background: #fff;
      box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
      padding: 1rem;
      border-radius: 4px;
      z-index: 20;
    }
    main {
      padding: 1.5rem 1.5rem 3rem;
      max-width: var(--pgm-ancho);
      margin: 0 auto;
      display: grid;
      gap: 1.5rem;
    }
  `,
})
export class MainLayoutComponent implements OnInit {
  readonly store = inject(ContextoStore);
  readonly auth = inject(AuthService);
  readonly entorno = environment.entorno;
  readonly menu = signal(false);
  readonly popup = signal<Entrada | null>(null);
  readonly iniciales = computed(() =>
    (this.store.nombre() ?? '')
      .split(/[\s.]+/)
      .filter(Boolean)
      .slice(0, 2)
      .map((p) => p[0]?.toUpperCase())
      .join(''),
  );
  readonly entradas: Entrada[] = [
    { ruta: '/inicio', texto: 'Inicio', clave: Visibilidad.INICIO },
    {
      popup: true,
      ruta: '/nueva-produccion',
      texto: 'N. Producción',
      clave: Visibilidad.NUEVA_PRODUCCION,
    },
    {
      popup: true,
      ruta: '/gestion-cartera',
      texto: 'Gest. Cartera',
      clave: Visibilidad.GESTION_CARTERA,
    },
    { popup: true, ruta: '/recibos', texto: 'Recibos', clave: Visibilidad.RECIBOS },
    { popup: true, ruta: '/prestaciones', texto: 'Prestaciones', clave: Visibilidad.PRESTACIONES },
    { ruta: '/gestion-comercial', texto: 'Gest. Comercial', clave: Visibilidad.GESTION_COMERCIAL },
    { ruta: '/utilidades', texto: 'Utilidades', clave: Visibilidad.UTILIDADES },
    { ruta: '/cuadro-mando', texto: 'Cuadro de mando', clave: Visibilidad.CUADRO_MANDO },
    { ruta: '/configuracion', texto: 'Configuración', clave: Visibilidad.CONFIGURACION },
  ];

  ngOnInit(): void {
    if (!this.store.cargado()) void this.store.cargar();
  }
}
