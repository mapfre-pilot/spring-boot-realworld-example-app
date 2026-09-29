/** SELECCION_PRODUCTO_AHORRO (VIA): grid de tarjetas de producto con filtro. */
import {
  ChangeDetectionStrategy,
  Component,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { toSignal } from '@angular/core/rxjs-interop';

import {
  EstadoSesion,
  Producto,
  EjecutarAccionUsecase,
  ObtenerProductosUsecase,
  SesionStore,
} from '@tva/core';
import { EncabezadoPantallaComponent } from '../../../../../shared/ui/layout/encabezado-pantalla/encabezado-pantalla.component';
import { EstadoVacioComponent } from '../../../../../shared/ui/feedback/estado-vacio/estado-vacio.component';
import { MATERIAL } from '../../../../../shared/ui/material';

export const MSG_SIN_PRODUCTOS = 'El servicio no ha devuelvo ningún producto de ahorro';

@Component({
  selector: 'app-seleccion-producto-ahorro',
  imports: [...MATERIAL, ReactiveFormsModule, EncabezadoPantallaComponent, EstadoVacioComponent],
  templateUrl: './seleccion-producto-ahorro.container.html',

  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SeleccionProductoAhorroContainer implements OnInit {
  private readonly obtenerProductos = inject(ObtenerProductosUsecase);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  private readonly store = inject(SesionStore);
  protected readonly MSG = MSG_SIN_PRODUCTOS;
  protected readonly productos = signal<Producto[]>([]);
  protected readonly filtro = new FormControl('', { nonNullable: true });
  private readonly textoFiltro = toSignal(this.filtro.valueChanges, { initialValue: '' });
  protected readonly productosFiltrados = computed(() => {
    const texto = this.textoFiltro().trim().toLowerCase();
    if (!texto) return this.productos();
    return this.productos().filter(
      p =>
        p.commercialProductCode.toLowerCase().includes(texto) ||
        p.commercialProductDesc.toLowerCase().includes(texto)
    );
  });

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

  protected contratar(p: Producto): void {
    this.ejecutarAccion
      .execute('seleccionar-modalidad', { productCode: p.commercialProductCode })
      .subscribe();
  }
}
