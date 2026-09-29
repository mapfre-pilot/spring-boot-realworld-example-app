/** RESULTADO_FIRMA: resultado de la firma y enlace a documentos. */
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatExpansionModule } from '@angular/material/expansion';
import { MatIconModule } from '@angular/material/icon';
import { MatListModule } from '@angular/material/list';

import { DocumentoFirma, EjecutarAccionUsecase, FirmaEstado, SesionStore } from '@tva/core';
import {
  ItemListaDatos,
  ListaDatosComponent,
} from '../../../../../shared/ui/contenedores/lista-datos/lista-datos.component';
import {
  PanelResultadoComponent,
  TipoPanel,
} from '../../../../../shared/ui/feedback/panel-resultado/panel-resultado.component';

const ESTADOS_OK = new Set(['SENT', 'SIGNED', 'COMPLETED', 'OK']);

@Component({
  selector: 'app-resultado-firma',
  imports: [
    MatButtonModule,
    MatExpansionModule,
    MatIconModule,
    MatListModule,
    PanelResultadoComponent,
    ListaDatosComponent,
  ],
  templateUrl: './resultado-firma.container.html',
  styleUrl: './resultado-firma.container.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ResultadoFirmaContainer {
  private readonly store = inject(SesionStore);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  protected readonly resultado = computed(() =>
    JSON.stringify(this.store.sesion()?.estado?.['firma'] ?? {}, null, 2)
  );
  protected readonly firma = computed(
    () => (this.store.sesion()?.estado?.['firma'] ?? {}) as FirmaEstado
  );
  protected readonly resp = computed(() => this.firma().response ?? {});
  protected readonly documentos = computed<DocumentoFirma[]>(() => this.resp().documents ?? []);
  protected readonly tipoPanel = computed<TipoPanel>(() =>
    ESTADOS_OK.has(String(this.resp().signatureStatus ?? '').toUpperCase()) ? 'ok' : 'error'
  );
  protected readonly mensaje = computed(() =>
    this.tipoPanel() === 'ok'
      ? 'La solicitud de firma se ha enviado correctamente.'
      : 'No se ha podido completar la firma.'
  );
  protected readonly items = computed<ItemListaDatos[]>(() => [
    { etiqueta: 'Tipo', valor: this.firma().tipo ?? null },
    { etiqueta: 'Estado', valor: this.resp().signatureStatus ?? null },
    { etiqueta: 'Solicitud', valor: this.resp().signatureRequestId ?? null },
  ]);

  protected finalizar(): void {
    this.ejecutarAccion.execute('siguiente', {}).subscribe();
  }
}
