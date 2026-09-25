/** Shell de sesión: carga la sesión y conmuta la pantalla activa. */
import { ChangeDetectionStrategy, Component, OnInit, computed, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { CargarSesionUsecase, EjecutarAccionUsecase, Pantalla, SesionStore } from '@tva/core';
import { AvisosComponent } from '../../ui/avisos.component';
import { CabeceraComponent } from '../../ui/cabecera.component';
import { MigasDePanComponent } from '../../ui/migas-de-pan.component';
import { BotoneraComponent } from '../../ui/botonera.component';

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
  styleUrl: './sesion.page.scss',
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './sesion.page.html',
})
export class SesionPage implements OnInit {
  readonly store = inject(SesionStore);
  private readonly route = inject(ActivatedRoute);
  private readonly cargarSesion = inject(CargarSesionUsecase);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  readonly P = Pantalla;

  readonly pasos = computed(() => PASOS[this.store.modalidad() ?? 'VA'] ?? []);

  ngOnInit(): void {
    const clave = this.route.snapshot.paramMap.get('clave');
    if (clave) this.cargarSesion.execute(clave).subscribe();
  }

  onAccion(id: string): void {
    this.ejecutarAccion.execute(id).subscribe();
  }
}
