/** Administración TVA (rol TVA_ADMIN_PORTAL): parámetros, apertura/cierre, cachés, trazas. */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTabsModule } from '@angular/material/tabs';

import {
  AlternarAperturaCierreUsecase,
  GuardarParametroUsecase,
  LimpiarCachesUsecase,
  ObtenerParametrosUsecase,
  ObtenerTrazasUsecase,
  Parametro,
  Traza,
} from '@tva/core';
import { CabeceraComponent } from '../../../shared/ui/layout/cabecera/cabecera.component';
import { EncabezadoPantallaComponent } from '../../../shared/ui/layout/encabezado-pantalla/encabezado-pantalla.component';
import { OperacionesAdminComponent } from '../operaciones-admin/operaciones-admin.component';
import { ParametrosAdminComponent } from '../parametros-admin/parametros-admin.component';
import { TrazasAdminComponent } from '../trazas-admin/trazas-admin.component';

@Component({
  selector: 'app-admin-page',
  imports: [
    MatCardModule,
    MatTabsModule,
    CabeceraComponent,
    EncabezadoPantallaComponent,
    ParametrosAdminComponent,
    OperacionesAdminComponent,
    TrazasAdminComponent,
  ],
  styleUrl: './admin.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './admin.page.html',
})
export class AdminPage implements OnInit {
  private readonly obtenerParametros = inject(ObtenerParametrosUsecase);
  private readonly guardarParametro = inject(GuardarParametroUsecase);
  private readonly alternarApertura = inject(AlternarAperturaCierreUsecase);
  private readonly limpiarCaches = inject(LimpiarCachesUsecase);
  private readonly obtenerTrazas = inject(ObtenerTrazasUsecase);

  protected readonly parametros = signal<Parametro[]>([]);
  protected readonly trazas = signal<Traza[]>([]);
  protected readonly estadoApertura = signal('');

  ngOnInit(): void {
    this.obtenerParametros.execute().subscribe(p => {
      this.parametros.set(p);
      const cerrada = p.find(x => x.clave === 'TVA_APLICACION_CERRADA');
      this.estadoApertura.set(cerrada?.valor === '1' ? 'cerrada' : 'abierta');
    });
  }

  protected guardar(p: Parametro, valor: string): void {
    this.guardarParametro.execute({ clave: p.clave, valor }).subscribe(n => {
      this.parametros.update(ps => ps.map(x => (x.clave === n.clave ? n : x)));
    });
  }

  protected apertura(): void {
    this.alternarApertura
      .execute()
      .subscribe(r => this.estadoApertura.set(r.cerrada ? 'cerrada' : 'abierta'));
  }

  protected fijarCierre(valor: '0' | '1'): void {
    this.guardarParametro.execute({ clave: 'TVA_APLICACION_CERRADA', valor }).subscribe(() => {
      this.estadoApertura.set(valor === '1' ? 'cerrada' : 'abierta');
      this.parametros.update(ps =>
        ps.map(x => (x.clave === 'TVA_APLICACION_CERRADA' ? { ...x, valor } : x))
      );
    });
  }

  protected limpiar(): void {
    this.limpiarCaches.execute().subscribe();
  }

  protected buscarTrazas(clave: string): void {
    this.obtenerTrazas.execute(clave || undefined).subscribe(t => this.trazas.set(t));
  }
}
