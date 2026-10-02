/** Shell de sesión: carga la sesión y conmuta la pantalla activa. */
import { ChangeDetectionStrategy, Component, OnInit, computed, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { CargarSesionUsecase, EjecutarAccionUsecase, Pantalla, SesionStore } from '@tva/core';
import { AvisosComponent } from '../../../shared/ui/feedback/avisos/avisos.component';
import { CabeceraComponent } from '../../../shared/ui/layout/cabecera/cabecera.component';
import { MigasDePanComponent } from '../../../shared/ui/layout/migas-de-pan/migas-de-pan.component';
import { BotoneraComponent } from '../../../shared/ui/layout/botonera/botonera.component';

import { CapturaDatosSolicitudContainer } from '../pantallas/solicitud/captura-datos-solicitud/captura-datos-solicitud.container';
import { CapturaTomador1Container } from '../pantallas/tomador/captura-tomador1/captura-tomador1.container';
import { CapturaTomador2Container } from '../pantallas/tomador/captura-tomador2/captura-tomador2.container';
import { FinContainer } from '../pantallas/cierre/fin/fin.container';
import { ModalidadCampaniaContainer } from '../pantallas/ahorro/modalidad-campania/modalidad-campania.container';
import { R2cCapturaContainer } from '../pantallas/rentas/r2c-captura/r2c-captura.container';
import { R2cPreciosContainer } from '../pantallas/rentas/r2c-precios/r2c-precios.container';
import { ResumenContratacionContainer } from '../pantallas/cierre/resumen-contratacion/resumen-contratacion.container';
import { ResultadoFirmaContainer } from '../pantallas/cierre/resultado-firma/resultado-firma.container';
import { SegurosAhorroContainer } from '../pantallas/ahorro/seguros-ahorro/seguros-ahorro.container';
import { SeleccionProductoAhorroContainer } from '../pantallas/ahorro/seleccion-producto-ahorro/seleccion-producto-ahorro.container';
import { SinPerfilContainer } from '../pantallas/avisos/sin-perfil/sin-perfil.container';
import { SistemaCerradoContainer } from '../pantallas/avisos/sistema-cerrado/sistema-cerrado.container';
import { SoloAvisosContainer } from '../pantallas/avisos/solo-avisos/solo-avisos.container';
import { AdminPanelComponent } from '../../admin/panel/admin-panel.component';
import { PASOS } from './sesion.const';

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
  templateUrl: './sesion.page.html',
})
export class SesionPage implements OnInit {
  readonly store = inject(SesionStore);
  private readonly route = inject(ActivatedRoute);
  private readonly cargarSesion = inject(CargarSesionUsecase);
  private readonly ejecutarAccion = inject(EjecutarAccionUsecase);
  protected readonly P = Pantalla;

  protected readonly pasos = computed(() => PASOS[this.store.modalidad() ?? 'VA'] ?? []);

  ngOnInit(): void {
    const clave = this.route.snapshot.paramMap.get('clave');
    if (clave) this.cargarSesion.execute(clave).subscribe();
  }

  protected onAccion(id: string): void {
    this.ejecutarAccion.execute(id).subscribe();
  }
}
