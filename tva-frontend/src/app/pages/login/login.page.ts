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
  templateUrl: './login.page.html',
  styleUrl: './login.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
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
