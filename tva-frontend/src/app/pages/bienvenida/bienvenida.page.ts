/** Pantalla de bienvenida: se muestra sin sesión activa; el acceso (SSO o
 *  token local) solo se inicia al pulsar el botón. */
import { ChangeDetectionStrategy, Component, OnInit, inject } from '@angular/core';
import { Router } from '@angular/router';

import { AuthService } from '@tva/core';
import { MATERIAL } from '../../shared/ui/material';

@Component({
  selector: 'app-bienvenida-page',
  imports: [...MATERIAL],
  templateUrl: './bienvenida.page.html',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class BienvenidaPage implements OnInit {
  protected readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  protected readonly anio = new Date().getFullYear();

  ngOnInit(): void {
    if (this.auth.autenticado()) void this.router.navigate(['/']);
  }

  protected iniciarSesion(): void {
    if (this.auth.authMode === 'oidc') {
      this.auth.loginOidc();
      return;
    }
    void this.router.navigate(['/login']);
  }
}
