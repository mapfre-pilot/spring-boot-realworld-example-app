import { Component } from '@angular/core';
import { RouterLink, RouterOutlet } from '@angular/router';
import { AuthService } from '../../infrastructure/auth/auth.service';
import { environment } from '../../../environments/environment';

@Component({
  selector: 'vida-main-layout',
  standalone: true,
  imports: [RouterLink, RouterOutlet],
  template: `
    <div class="layout">
      <aside class="sidebar">
        <a class="brand" routerLink="/">Vida 372</a>
        <nav aria-label="Navegación principal">
          <a routerLink="/expedientes">Búsqueda de expedientes</a>
          <a routerLink="/expedientes/nuevo">Alta / gestión</a>
          <a routerLink="/variables">Variables</a>
          <a routerLink="/finiquitos">Emisión de finiquitos</a>
          <a routerLink="/informes">Impresión de informes</a>
          <a routerLink="/bdgi">Petición BDGI</a>
          <a routerLink="/reaseguro">Reaseguro</a>
          <a routerLink="/cartera-poliza">Cartera de póliza</a>
          <a routerLink="/carteras"
            >Carteras <span class="provisional">provisional</span></a
          >
          <a routerLink="/carga-fichero">Carga de fichero</a>
        </nav>
        @if (authEnabled) {
        <button type="button" class="logout" (click)="auth.login()">
          Iniciar sesión
        </button>
        } @else {
        <p class="logout">Entorno local</p>
        }
      </aside>
      <main class="content"><router-outlet /></main>
    </div>
  `,
  styles: [
    `
      .layout {
        min-height: 100vh;
        display: grid;
        grid-template-columns: 250px 1fr;
      }
      .sidebar {
        background: #102b4e;
        color: white;
        display: flex;
        flex-direction: column;
        gap: 1.5rem;
        padding: 1.5rem 1rem;
      }
      .brand {
        color: white;
        font-size: 1.35rem;
        font-weight: 700;
        text-decoration: none;
      }
      nav {
        display: grid;
        gap: 0.35rem;
      }
      nav a {
        color: #edf4ff;
        padding: 0.7rem;
        border-radius: 0.35rem;
        text-decoration: none;
      }
      nav a:hover,
      nav a:focus {
        background: #224d7a;
      }
      .provisional {
        color: #ffdf8a;
        font-size: 0.75rem;
      }
      .logout {
        margin-top: auto;
      }
      .content {
        padding: 2rem;
        min-width: 0;
      }
      @media (max-width: 760px) {
        .layout {
          grid-template-columns: 1fr;
        }
        .sidebar {
          gap: 0.8rem;
        }
        nav {
          grid-template-columns: repeat(2, minmax(0, 1fr));
        }
        .content {
          padding: 1rem;
        }
      }
    `,
  ],
})
export class MainLayoutComponent {
  readonly authEnabled = environment.auth.enabled;

  constructor(readonly auth: AuthService) {}
}
