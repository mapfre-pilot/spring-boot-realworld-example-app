/** Shell de sesión: carga la sesión y conmuta la pantalla activa. */
import { ChangeDetectionStrategy, Component, OnInit, computed, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { Pantalla } from '../../core/models/models';
import { SesionStore } from '../../core/state/sesion.store';
import { AvisosComponent } from '../../shared/ui/avisos.component';
import { CabeceraComponent } from '../../shared/ui/cabecera.component';
import { MigasDePanComponent } from '../../shared/ui/migas-de-pan.component';
import { BotoneraComponent } from '../../shared/ui/botonera.component';

import { CapturaDatosSolicitudContainer } from './pantallas/captura-datos-solicitud.container';
import { CapturaTomador1Container } from './pantallas/captura-tomador1.container';
import { CapturaTomador2Container } from './pantallas/captura-tomador2.container';
import { FinContainer } from './pantallas/fin.container';
import { ModalidadCampaniaContainer } from './pantallas/modalidad-campania.container';
import { R2cCapturaContainer } from './pantallas/r2c-captura.container';
import { R2cPreciosContainer } from './pantallas/r2c-precios.container';
import { ResumenContratacionContainer } from './pantallas/resumen-contratacion.container';
import { ResultadoFirmaContainer } from './pantallas/resultado-firma.container';
import { SegurosAhorroContainer } from './pantallas/seguros-ahorro.container';
import { SeleccionProductoAhorroContainer } from './pantallas/seleccion-producto-ahorro.container';
import { SinPerfilContainer } from './pantallas/sin-perfil.container';
import { SistemaCerradoContainer } from './pantallas/sistema-cerrado.container';
import { SoloAvisosContainer } from './pantallas/solo-avisos.container';
import { AdminPanelComponent } from '../admin/admin-panel.component';

const PASOS: Record<string, Pantalla[]> = {
  VA: [
    Pantalla.SEGUROS_AHORRO,
    Pantalla.CAPTURA_DATOS_SOLICITUD,
    Pantalla.CAPTURA_TOMADOR1,
    Pantalla.CAPTURA_TOMADOR2,
    Pantalla.RESUMEN_CONTRATACION,
    Pantalla.RESULTADO_FIRMA,
    Pantalla.FIN,
  ],
  VIA: [
    Pantalla.SELECCION_PRODUCTO_AHORRO,
    Pantalla.MODALIDAD_CAMPANIA,
    Pantalla.CAPTURA_DATOS_SOLICITUD,
    Pantalla.CAPTURA_TOMADOR1,
    Pantalla.RESUMEN_CONTRATACION,
    Pantalla.RESULTADO_FIRMA,
    Pantalla.FIN,
  ],
  R2C: [
    Pantalla.R2C_CAPTURA,
    Pantalla.R2C_PRECIOS,
    Pantalla.RESUMEN_CONTRATACION,
    Pantalla.RESULTADO_FIRMA,
    Pantalla.FIN,
  ],
};

@Component({
  selector: 'app-sesion-page',
  imports: [
    MatProgressSpinnerModule,
    CabeceraComponent,
    MigasDePanComponent,
    AvisosComponent,
    SegurosAhorroContainer,
    SeleccionProductoAhorroContainer,
    ModalidadCampaniaContainer,
    CapturaDatosSolicitudContainer,
    CapturaTomador1Container,
    CapturaTomador2Container,
    R2cCapturaContainer,
    R2cPreciosContainer,
    ResumenContratacionContainer,
    ResultadoFirmaContainer,
    FinContainer,
    SistemaCerradoContainer,
    SinPerfilContainer,
    SoloAvisosContainer,
    AdminPanelComponent,
    BotoneraComponent,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <app-cabecera [modalidad]="store.modalidad()" />
    <div class="pagina">
      @if (store.cargando()) {
        <mat-spinner />
      } @else if (store.sesion(); as sesion) {
        <app-migas-de-pan [pasos]="pasos()" [actual]="store.pantallaActual()" />
        <app-avisos [avisos]="store.avisos()" />
        @switch (store.pantallaActual()) {
          @case (P.SEGUROS_AHORRO) {
            <app-seguros-ahorro />
          }
          @case (P.SELECCION_PRODUCTO_AHORRO) {
            <app-seleccion-producto-ahorro />
          }
          @case (P.MODALIDAD_CAMPANIA) {
            <app-modalidad-campania />
          }
          @case (P.CAPTURA_DATOS_SOLICITUD) {
            <app-captura-datos-solicitud />
          }
          @case (P.CAPTURA_TOMADOR1) {
            <app-tomador1 />
          }
          @case (P.CAPTURA_TOMADOR2) {
            <app-tomador2 />
          }
          @case (P.R2C_CAPTURA) {
            <app-r2c-captura />
          }
          @case (P.R2C_PRECIOS) {
            <app-r2c-precios />
          }
          @case (P.RESUMEN_CONTRATACION) {
            <app-resumen-contratacion />
          }
          @case (P.RESULTADO_FIRMA) {
            <app-resultado-firma />
          }
          @case (P.FIN) {
            <app-fin />
          }
          @case (P.SISTEMA_CERRADO) {
            <app-sistema-cerrado />
          }
          @case (P.SIN_PERFIL) {
            <app-sin-perfil />
          }
          @case (P.SOLO_AVISOS) {
            <app-solo-avisos />
          }
          @case (P.ADMINISTRACION) {
            <app-admin-panel />
          }
        }
        <app-botonera [botones]="store.botones()" (accion)="onAccion($event)" />
      }
    </div>
  `,
  styles: `
    .pagina {
      max-width: 960px;
      margin: 16px auto;
      padding: 0 16px;
    }
    mat-spinner {
      display: block;
      margin: 48px auto;
    }
  `,
})
export class SesionPage implements OnInit {
  readonly store = inject(SesionStore);
  private readonly route = inject(ActivatedRoute);
  readonly P = Pantalla;

  readonly pasos = computed(() => PASOS[this.store.modalidad() ?? 'VA'] ?? []);

  ngOnInit(): void {
    const clave = this.route.snapshot.paramMap.get('clave');
    if (clave) this.store.cargar(clave).subscribe();
  }

  onAccion(id: string): void {
    this.store.ejecutar(id).subscribe();
  }
}
