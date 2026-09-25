/** Administración TVA (rol TVA_ADMIN_PORTAL): parámetros, apertura/cierre, cachés, trazas. */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';

import {
  AlternarAperturaCierreUsecase,
  GuardarParametroUsecase,
  LimpiarCachesUsecase,
  ObtenerParametrosUsecase,
  ObtenerTrazasUsecase,
  Parametro,
  Traza,
} from '@tva/core';
import { CabeceraComponent } from '../../ui/cabecera.component';

@Component({
  selector: 'app-admin-page',
  imports: [
    ReactiveFormsModule,
    MatTableModule,
    MatButtonModule,
    MatInputModule,
    CabeceraComponent,
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

  readonly parametros = signal<Parametro[]>([]);
  readonly trazas = signal<Traza[]>([]);
  readonly estadoApertura = signal('');
  readonly columnas = ['clave', 'valor', 'tipo'];
  readonly columnasTrazas = ['creado', 'clase', 'mensaje'];
  readonly trazaForm = inject(FormBuilder).nonNullable.group({ clave: [''] });

  ngOnInit(): void {
    this.obtenerParametros.execute().subscribe(p => {
      this.parametros.set(p);
      const cerrada = p.find(x => x.clave === 'TVA_APLICACION_CERRADA');
      this.estadoApertura.set(cerrada?.valor === '1' ? 'cerrada' : 'abierta');
    });
  }

  guardar(p: Parametro, valor: string): void {
    this.guardarParametro.execute({ clave: p.clave, valor }).subscribe(n => {
      this.parametros.update(ps => ps.map(x => (x.clave === n.clave ? n : x)));
    });
  }

  apertura(): void {
    this.alternarApertura
      .execute()
      .subscribe(r => this.estadoApertura.set(r.cerrada ? 'cerrada' : 'abierta'));
  }

  fijarCierre(valor: '0' | '1'): void {
    this.guardarParametro.execute({ clave: 'TVA_APLICACION_CERRADA', valor }).subscribe(() => {
      this.estadoApertura.set(valor === '1' ? 'cerrada' : 'abierta');
      this.parametros.update(ps =>
        ps.map(x => (x.clave === 'TVA_APLICACION_CERRADA' ? { ...x, valor } : x))
      );
    });
  }

  limpiar(): void {
    this.limpiarCaches.execute().subscribe();
  }

  buscarTrazas(): void {
    this.obtenerTrazas
      .execute(this.trazaForm.value.clave ?? undefined)
      .subscribe(t => this.trazas.set(t));
  }
}
