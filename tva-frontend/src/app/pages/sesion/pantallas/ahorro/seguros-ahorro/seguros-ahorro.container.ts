/** SEGUROS_AHORRO (VA): tabla de insurancesApplication de la propuesta (TVA_Pantalla_SegurosAhorro). */
import { CurrencyPipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, computed, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';

import {
  EjecutarAccionUsecase,
  EstadoSesion,
  InsuranceApplicationProposal,
  SesionStore,
} from '@tva/core';
import { CajaComponent } from '../../../../../shared/ui/contenedores/caja/caja.component';
import { EncabezadoPantallaComponent } from '../../../../../shared/ui/layout/encabezado-pantalla/encabezado-pantalla.component';
import { EstadoVacioComponent } from '../../../../../shared/ui/feedback/estado-vacio/estado-vacio.component';

@Component({
  selector: 'app-seguros-ahorro',
  imports: [
    MatCardModule,
    MatButtonModule,
    CajaComponent,
    CurrencyPipe,
    EncabezadoPantallaComponent,
    EstadoVacioComponent,
  ],
  templateUrl: './seguros-ahorro.container.html',

  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SegurosAhorroContainer {
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  private readonly store = inject(SesionStore);

  private readonly estado = computed(() => (this.store.sesion()?.estado ?? {}) as EstadoSesion);

  protected readonly subtitulo = computed(() => {
    const id = this.estado()['proposalId'] ?? this.estado()['propuestaId'];
    return id ? `Propuesta ${String(id)}` : undefined;
  });

  protected readonly applications = computed<InsuranceApplicationProposal[]>(() => {
    const prop = (this.estado().responseProposal ?? {}) as Record<string, unknown>;
    const contracting = (prop['contractingProposal'] ?? {}) as Record<string, unknown>;
    return (
      (contracting['insurancesApplication'] as InsuranceApplicationProposal[] | undefined) ?? []
    );
  });

  /** TVA_Pantalla_SegurosAhorro: en VA sin la funcionalidad 4045 hace falta
   * test de conveniencia vigente en todos los tomadores para poder capturar. */
  protected readonly capturaDeshabilitada = computed(() => {
    const estado = this.estado();
    if ((this.store.sesion()?.modalidad ?? estado.modoFuncionamiento) !== 'VA') return false;
    const funcionalidades = estado.perfilUsuario?.funcionalidades ?? [];
    if (funcionalidades.map(String).includes('4045')) return false;
    const tomadores = estado.tomadores ?? [];
    return !tomadores.length
      ? true
      : tomadores.some(t => !t.datosGestionParticipante?.testConvenienciaVigente);
  });

  protected capturar(ap: InsuranceApplicationProposal): void {
    this.ejecutarAccion
      .execute('seleccionar-modalidad', { productCode: ap.commercialProductCode })
      .subscribe();
  }
}
