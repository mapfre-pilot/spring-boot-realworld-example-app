/** Administración TVA (rol TVA_ADMIN_PORTAL): parámetros, apertura/cierre, cachés, trazas. */
import { ChangeDetectionStrategy, Component, OnInit, inject, signal } from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { MatButtonModule } from '@angular/material/button';
import { MatInputModule } from '@angular/material/input';
import { MatTableModule } from '@angular/material/table';

import { TvaApiService } from '../../core/api/tva-api.service';
import { Parametro, Traza } from '../../core/models/models';
import { CabeceraComponent } from '../../shared/ui/cabecera.component';

@Component({
  selector: 'app-admin-page',
  imports: [
    ReactiveFormsModule,
    MatTableModule,
    MatButtonModule,
    MatInputModule,
    CabeceraComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-cabecera />
    <div class="pagina">
      <h2>Parámetros</h2>
      <table mat-table [dataSource]="parametros()" class="tabla">
        <ng-container matColumnDef="clave"
          ><th mat-header-cell *matHeaderCellDef>Clave</th>
          <td mat-cell *matCellDef="let p">{{ p.clave }}</td></ng-container
        >
        <ng-container matColumnDef="valor">
          <th mat-header-cell *matHeaderCellDef>Valor</th>
          <td mat-cell *matCellDef="let p">
            <input matInput [value]="p.valor" (change)="guardar(p, $any($event.target).value)" />
          </td>
        </ng-container>
        <ng-container matColumnDef="tipo"
          ><th mat-header-cell *matHeaderCellDef>Tipo</th>
          <td mat-cell *matCellDef="let p">{{ p.tipo }}</td></ng-container
        >
        <tr mat-header-row *matHeaderRowDef="columnas"></tr>
        <tr mat-row *matRowDef="let row; columns: columnas"></tr>
      </table>

      <h2>Operaciones</h2>
      <button mat-stroked-button (click)="apertura()">Alternar apertura/cierre</button>
      <button mat-stroked-button (click)="limpiar()">Limpiar cachés</button>
      <p>Estado apertura: {{ estadoApertura() }}</p>

      <h2>Trazas</h2>
      <form [formGroup]="trazaForm" (ngSubmit)="buscarTrazas()">
        <input matInput formControlName="clave" placeholder="Clave de sesión (opcional)" />
        <button mat-stroked-button type="submit">Buscar</button>
      </form>
      <table mat-table [dataSource]="trazas()" class="tabla">
        <ng-container matColumnDef="creado"
          ><th mat-header-cell *matHeaderCellDef>Creado</th>
          <td mat-cell *matCellDef="let t">{{ t.creado }}</td></ng-container
        >
        <ng-container matColumnDef="clase"
          ><th mat-header-cell *matHeaderCellDef>Clase</th>
          <td mat-cell *matCellDef="let t">{{ t.clase }}</td></ng-container
        >
        <ng-container matColumnDef="mensaje"
          ><th mat-header-cell *matHeaderCellDef>Mensaje</th>
          <td mat-cell *matCellDef="let t">{{ t.mensaje }}</td></ng-container
        >
        <tr mat-header-row *matHeaderRowDef="columnasTrazas"></tr>
        <tr mat-row *matRowDef="let row; columns: columnasTrazas"></tr>
      </table>
    </div>
  `,
  styles: `
    .pagina {
      max-width: 960px;
      margin: 16px auto;
      padding: 0 16px;
    }
    .tabla {
      width: 100%;
      margin-bottom: 24px;
    }
    button {
      margin-right: 8px;
    }
  `,
})
export class AdminPage implements OnInit {
  private readonly api = inject(TvaApiService);

  readonly parametros = signal<Parametro[]>([]);
  readonly trazas = signal<Traza[]>([]);
  readonly estadoApertura = signal('');
  readonly columnas = ['clave', 'valor', 'tipo'];
  readonly columnasTrazas = ['creado', 'clase', 'mensaje'];
  readonly trazaForm = inject(FormBuilder).nonNullable.group({ clave: [''] });

  ngOnInit(): void {
    this.api.adminParametros().subscribe(p => this.parametros.set(p));
  }

  guardar(p: Parametro, valor: string): void {
    this.api.adminPutParametro({ clave: p.clave, valor }).subscribe(n => {
      this.parametros.update(ps => ps.map(x => (x.clave === n.clave ? n : x)));
    });
  }

  apertura(): void {
    this.api
      .adminAperturaCierre()
      .subscribe(r => this.estadoApertura.set(r.cerrada ? 'cerrada' : 'abierta'));
  }

  limpiar(): void {
    this.api.adminLimpiarCaches().subscribe();
  }

  buscarTrazas(): void {
    this.api
      .adminTrazas(this.trazaForm.value.clave ?? undefined)
      .subscribe(t => this.trazas.set(t));
  }
}
