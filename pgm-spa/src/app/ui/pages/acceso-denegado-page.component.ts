import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'pgm-acceso-denegado-page',
  imports: [RouterLink],
  template: `
    <section class="card">
      <h1>Sin acceso</h1>
      <p>
        Tu perfil no tiene la visibilidad <code>{{ clave() }}</code
        >. Las visibilidades las determina el BFF a partir de tus grupos de Entra ID, tu perfil SGC
        3.0 y tu estructura comercial.
      </p>
      <a class="btn" routerLink="/inicio">Volver a inicio</a>
    </section>
  `,
})
export class AccesoDenegadoPageComponent {
  readonly clave = input<string>('');
}
