/** Login local: pega el token generado con `manage.py crear_token_local`. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { Router } from '@angular/router';

import { AuthService } from '../../core/auth/auth.service';

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
      <mat-card>
        <mat-card-title>Tarificador Vida Ahorro — acceso</mat-card-title>
        <mat-card-content>
          @if (auth.authMode === 'local') {
            <p>Pega el token local generado con <code>manage.py crear_token_local</code>.</p>
            <form [formGroup]="form" (ngSubmit)="entrar()">
              <mat-form-field appearance="outline" class="campo">
                <mat-label>Token JWT local</mat-label>
                <textarea matInput formControlName="token" rows="3"></textarea>
              </mat-form-field>
              <button mat-flat-button color="primary" type="submit" [disabled]="form.invalid">
                Entrar
              </button>
            </form>
          } @else {
            <p>Acceso corporativo (OIDC).</p>
            <button mat-flat-button color="primary" (click)="auth.loginOidc()">
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
      padding-top: 10vh;
    }
    mat-card {
      max-width: 480px;
      width: 100%;
    }
    .campo {
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
