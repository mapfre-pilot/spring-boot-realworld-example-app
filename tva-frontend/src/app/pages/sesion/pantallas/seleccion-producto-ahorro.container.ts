/** SELECCION_PRODUCTO_AHORRO (VIA): grid de tarjetas de producto, link "Contratación". */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

import { EstadoSesion, Producto } from '../../../core/models/models';
import { TvaApiService } from '../../../core/api/tva-api.service';
import { SesionStore } from '../../../core/state/sesion.store';

export const MSG_SIN_PRODUCTOS = 'El servicio no ha devuelvo ningún producto de ahorro';

@Component({
  selector: 'app-seleccion-producto-ahorro',
  imports: [MatCardModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (productos().length === 0) {
      <p>{{ MSG }}</p>
    }
    <div class="grid">
      @for (p of productos(); track p.commercialProductCode) {
        <mat-card class="tarjeta">
          <mat-card-title
            >{{ p.commercialProductCode }} - {{ p.commercialProductDesc }}</mat-card-title
          >
          <mat-card-content>
            <a href="#" (click)="contratar(p); $event.preventDefault()">Contratación</a>
          </mat-card-content>
        </mat-card>
      }
    </div>
  `,
  styles: `
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 12px;
    }
    .tarjeta a {
      color: #d81e05;
    }
  `,
})
export class SeleccionProductoAhorroContainer implements OnInit {
  private readonly api = inject(TvaApiService);
  private readonly store = inject(SesionStore);
  readonly MSG = MSG_SIN_PRODUCTOS;
  readonly productos = signal<Producto[]>([]);

  ngOnInit(): void {
    const estado = (this.store.sesion()?.estado ?? {}) as EstadoSesion;
    const enEstado = (estado['productos'] as Producto[] | undefined) ?? [];
    if (enEstado.length) {
      this.productos.set(enEstado);
      return;
    }
    const perfil = estado.perfilUsuario ?? {};
    this.api
      .productos({
        companyId: estado.companyId ?? undefined,
        nuuma: perfil.nuuma,
        distributionChannel: estado.distributionChannel ?? undefined,
      })
      .subscribe(r => this.productos.set(r.products ?? []));
  }

  contratar(p: Producto): void {
    this.store
      .ejecutar('seleccionar-modalidad', { productCode: p.commercialProductCode })
      .subscribe();
  }
}
