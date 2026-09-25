/** Login local: pega el token generado con `manage.py crear_token_local`. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { Router } from '@angular/router';

import { AuthService } from '@tva/core';

@Component({
  selector: 'app-login-page',
  imports: [
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    ReactiveFormsModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="contenedor">
      <mat-card class="login-card">
        <mat-card-content>
          <div class="marca">MAPFRE</div>
          <p class="subtitulo">Tarificador Vida Ahorro</p>
          @if (auth.authMode === 'local') {
            <p class="ayuda">
              Pega el token local generado con <code>manage.py crear_token_local</code>.
            </p>
            <form [formGroup]="form" (ngSubmit)="entrar()">
              <mat-form-field appearance="outline" class="campo">
                <mat-label>Token JWT local</mat-label>
                <textarea matInput formControlName="token" rows="3"></textarea>
              </mat-form-field>
              <button
                mat-flat-button
                color="primary"
                type="submit"
                class="entrar"
                [disabled]="form.invalid">
                Entrar
              </button>
            </form>
          } @else {
            <p class="ayuda">Acceso corporativo (OIDC).</p>
            <button mat-flat-button color="primary" class="entrar" (click)="auth.loginOidc()">
              Entrar con SSO
            </button>
          }
        </mat-card-content>
      </mat-card>
    </div>
  `,
  styles: `
    .contenedor {
      display: flex;
      justify-content: center;
      padding-top: 12vh;
    }
    .login-card {
      max-width: 480px;
      width: 100%;
    }
    .login-card mat-card-content {
      padding: 32px 28px 28px;
    }
    .marca {
      color: var(--tva-primary, #d81e05);
      font-size: 24px;
      font-weight: 700;
      letter-spacing: 3px;
    }
    .subtitulo {
      font-size: 14px;
      font-weight: 500;
      color: var(--tva-text-muted, #666);
      margin: 2px 0 20px;
    }
    .ayuda {
      font-size: 13px;
      color: var(--tva-text-muted, #666);
    }
    .campo {
      width: 100%;
    }
    .entrar {
      width: 100%;
    }
  `,
})
export class LoginPage {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  readonly form = inject(FormBuilder).nonNullable.group({ token: ['', Validators.required] });

  entrar(): void {
    this.auth.login(this.form.value.token ?? '');
    void this.router.navigate(['/']);
  }
}
