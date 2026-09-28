/** Login local: pega el token generado con `manage.py crear_token_local`. */
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';

import { AuthService } from '@tva/core';
import { MATERIAL } from '../../shared/ui/material';

@Component({
  selector: 'app-login-page',
  imports: [...MATERIAL, ReactiveFormsModule],
  templateUrl: './login.page.html',
  styleUrl: './login.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class LoginPage {
  readonly auth = inject(AuthService);
  private readonly router = inject(Router);
  protected readonly form = inject(FormBuilder).nonNullable.group({
    token: ['', Validators.required],
  });

  protected entrar(): void {
    this.auth.login(this.form.value.token ?? '');
    void this.router.navigate(['/']);
  }
}
