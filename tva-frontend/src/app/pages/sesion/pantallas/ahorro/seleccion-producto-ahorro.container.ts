/** SELECCION_PRODUCTO_AHORRO (VIA): grid de tarjetas de producto, link "Contratación". */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { MatCardModule } from '@angular/material/card';

import {
  EstadoSesion,
  Producto,
  EjecutarAccionUsecase,
  ObtenerProductosUsecase,
  SesionStore,
} from '@tva/core';

export const MSG_SIN_PRODUCTOS = 'El servicio no ha devuelvo ningún producto de ahorro';

@Component({
  selector: 'app-seleccion-producto-ahorro',
  imports: [MatCardModule],
  templateUrl: './seleccion-producto-ahorro.container.html',
  styleUrl: './seleccion-producto-ahorro.container.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SeleccionProductoAhorroContainer implements OnInit {
  private readonly obtenerProductos = inject(ObtenerProductosUsecase);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
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
    this.obtenerProductos
      .execute({
        companyId: estado.companyId ?? undefined,
        nuuma: perfil.nuuma,
        distributionChannel: estado.distributionChannel ?? undefined,
      })
      .subscribe(r => this.productos.set(r.products ?? []));
  }

  contratar(p: Producto): void {
    this.ejecutarAccion
      .execute('seleccionar-modalidad', { productCode: p.commercialProductCode })
      .subscribe();
  }
}
