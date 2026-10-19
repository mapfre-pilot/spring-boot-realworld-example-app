import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { PGM_REPOSITORY } from '../../application/ports/pgm.repository';
import { Recibo } from '../../domain/models/api.models';
import { EstadoComponent } from '../components/estado.component';
import { Columna, TablaExportableComponent } from '../components/tabla-exportable.component';

/** /recibos — consulta de recibos por cliente, por póliza o por número de recibo. */
@Component({
  selector: 'pgm-recibos-page',
  imports: [FormsModule, EstadoComponent, TablaExportableComponent],
  template: `
    <section class="card">
      <h1>Recibos</h1>
      <form class="grid grid-4" (ngSubmit)="buscar()">
        <label>Nº recibo <input name="recibo" [(ngModel)]="recibo" /></label>
        <label>Nº póliza <input name="poliza" [(ngModel)]="poliza" /></label>
        <label>Documento del cliente <input name="documento" [(ngModel)]="documento" /></label>
        <div class="row" style="align-items:flex-end"><button class="btn" type="submit">Consultar</button></div>
      </form>
      <pgm-estado [cargando]="cargando()" [error]="error()" />
    </section>
    @if (resultados() !== null) {
      <section class="card">
        <pgm-tabla-exportable titulo="Recibos" nombreFichero="recibos" [columnas]="columnas" [filas]="resultados()!" />
      </section>
    }
  `,
})
export class RecibosPageComponent {
  private readonly repo = inject(PGM_REPOSITORY);
  private readonly router = inject(Router);
  recibo = ''; poliza = ''; documento = '';
  readonly resultados = signal<Recibo[] | null>(null);
  readonly cargando = signal(false);
  readonly error = signal<string | null>(null);
  readonly columnas: Columna<Recibo>[] = [
    { clave: 'numero', titulo: 'Recibo' }, { clave: 'polizaNumero', titulo: 'Póliza' }, { clave: 'ramo', titulo: 'Ramo' }, { clave: 'estado', titulo: 'Estado' },
    { clave: 'importe', titulo: 'Importe (€)' }, { clave: 'fechaEmision', titulo: 'Emisión' }, { clave: 'fechaVencimiento', titulo: 'Vencimiento' }, { clave: 'formaPago', titulo: 'Forma de pago' },
  ];

  async buscar(): Promise<void> {
    this.cargando.set(true); this.error.set(null);
    try {
      if (this.recibo.trim()) {
        void this.router.navigate(['/recibos', this.recibo.trim()]);
      } else if (this.poliza.trim()) {
        this.resultados.set((await firstValueFrom(this.repo.recibosPoliza(this.poliza.trim()))).items);
      } else if (this.documento.trim()) {
        const clientes = await firstValueFrom(this.repo.buscarClientes({ documento: this.documento.trim() }));
        if (!clientes.items.length) throw new Error('No existe ningún cliente con ese documento');
        this.resultados.set((await firstValueFrom(this.repo.recibosCliente(clientes.items[0].id))).items);
      } else {
        throw new Error('Indica un número de recibo, de póliza o el documento del cliente');
      }
    } catch (e) {
      this.error.set((e as Error).message);
    } finally {
      this.cargando.set(false);
    }
  }
}
