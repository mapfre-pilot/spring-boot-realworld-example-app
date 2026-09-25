/** CAPTURA_TOMADOR1 — caja Datos del tomador + panel de requisitos (§12.2). */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { MatTooltipModule } from '@angular/material/tooltip';

import { CajaComponent } from '../../../ui/caja.component';
import { CampoSelectComponent } from '../../../ui/campo-select.component';
import { CampoTextoComponent } from '../../../ui/campo-texto.component';
import { SeccionComponent } from '../../../ui/seccion.component';
import { TomadorBase } from './tomador-base';

export const TOMADOR_TEMPLATE = `
<div class="layout">
  <div class="col-izq">
    <app-caja titulo="Datos del tomador">
      <app-seccion titulo="Datos personales" [valida]="seccionValida('datosPersonales')"
        [expandida]="expandida() === 'datosPersonales'" [avisos]="avisos()" [seccion]="cajaId + '/datosPersonales'"
        (continuar)="continuar('datosPersonales', datosPersonales)">
        <form [formGroup]="datosPersonales" class="formulario">
          <app-campo-texto [control]="datosPersonales.controls.documentId" etiqueta="Nº documento" />
          <app-campo-texto [control]="datosPersonales.controls.nombre" etiqueta="Nombre" />
          <app-campo-texto [control]="datosPersonales.controls.primerApellido" etiqueta="Primer apellido" />
          <app-campo-texto [control]="datosPersonales.controls.segundoApellido" etiqueta="Segundo apellido" />
          <app-campo-texto [control]="datosPersonales.controls.fechaNacimiento" etiqueta="Fecha de nacimiento" tipo="date" />
          <app-campo-select [control]="datosPersonales.controls.sexo" etiqueta="Sexo" [opciones]="catalogos()['sexos'] ?? []" />
          <app-campo-select [control]="datosPersonales.controls.nacionalidad" etiqueta="Nacionalidad" [opciones]="catalogos()['nacionalidades'] ?? []" />
          <app-campo-select [control]="datosPersonales.controls.paisNacimiento" etiqueta="País de nacimiento" [opciones]="catalogos()['paises'] ?? []" />
          <app-campo-select [control]="datosPersonales.controls.actividad" etiqueta="Actividad" [opciones]="catalogos()['actividades'] ?? []" />
          <app-campo-select [control]="datosPersonales.controls.sector" etiqueta="Sector" [opciones]="catalogos()['sectores'] ?? []" />
          <app-campo-select [control]="datosPersonales.controls.profesion" etiqueta="Profesión" [opciones]="catalogos()['profesiones'] ?? []" />
          <mat-checkbox formControlName="responsabilidadPublica">Prevención de blanqueo de capitales (declara que es o ha sido)</mat-checkbox>
          <mat-slide-toggle formControlName="residenciaHabitualEspanya">Residencia habitual en España</mat-slide-toggle>
        </form>
      </app-seccion>

      <app-seccion titulo="Domicilio habitual" [valida]="seccionValida('domicilioHabitual')"
        [expandida]="expandida() === 'domicilioHabitual'" [avisos]="avisos()" [seccion]="cajaId + '/domicilioHabitual'"
        (continuar)="continuar('domicilioHabitual', domicilioHabitual)">
        <form [formGroup]="domicilioHabitual" class="formulario">
          <app-campo-select [control]="domicilioHabitual.controls.tipoVia" etiqueta="Tipo de vía" [opciones]="catalogos()['tiposVia'] ?? []" />
          <app-campo-texto [control]="domicilioHabitual.controls.nombreVia" etiqueta="Nombre de la vía" />
          <app-campo-texto [control]="domicilioHabitual.controls.numero" etiqueta="Número" />
          <app-campo-texto [control]="domicilioHabitual.controls.complementoDireccion" etiqueta="Complemento de dirección" />
          <app-campo-texto [control]="domicilioHabitual.controls.codigoPostal" etiqueta="Código postal" />
          <app-campo-texto [control]="domicilioHabitual.controls.localidad" etiqueta="Localidad" />
          <app-campo-select [control]="domicilioHabitual.controls.provincia" etiqueta="Provincia" [opciones]="catalogos()['provincias'] ?? []" />
          <app-campo-select [control]="domicilioHabitual.controls.pais" etiqueta="País" [opciones]="catalogos()['paises'] ?? []" />
        </form>
      </app-seccion>

      <app-seccion titulo="Medios de contacto" [valida]="seccionValida('mediosContacto')"
        [expandida]="expandida() === 'mediosContacto'" [avisos]="avisos()" [seccion]="cajaId + '/mediosContacto'"
        (continuar)="continuarMedios()">
        <form [formGroup]="mediosContacto" class="formulario">
          <app-campo-select [control]="mediosContacto.controls.tipo" etiqueta="Tipo de teléfono" [opciones]="catalogos()['tiposMedioContacto'] ?? []" />
          <app-campo-texto [control]="mediosContacto.controls.prefijo" etiqueta="Prefijo" />
          <app-campo-texto [control]="mediosContacto.controls.numero" etiqueta="Número" />
        </form>
        <form [formGroup]="correo" class="formulario">
          <app-campo-texto [control]="correo.controls.contactMethodValue" etiqueta="Correo electrónico" tipo="email" />
        </form>
      </app-seccion>

      <app-seccion titulo="Residencia fiscal (FATCA/CRS)" [valida]="seccionValida('fatcaCrs')"
        [expandida]="expandida() === 'fatcaCrs'" [avisos]="avisos()" [seccion]="cajaId + '/fatcaCrs'"
        (continuar)="continuarFatca()">
        <form [formGroup]="fatcaCrs">
          <mat-slide-toggle formControlName="residenteFiscalOtroPais">Es residente fiscal en un país diferente a España</mat-slide-toggle>
        </form>
      </app-seccion>

      <app-seccion titulo="Representante legal" [valida]="seccionValida('legalRepresentative')"
        [expandida]="expandida() === 'legalRepresentative'" [avisos]="avisos()" [seccion]="cajaId + '/legalRepresentative'"
        (continuar)="continuarRepresentante()">
        <mat-slide-toggle [checked]="hayRepresentante()" (change)="hayRepresentante.set($event.checked)">Tiene representante legal</mat-slide-toggle>
        @if (hayRepresentante()) {
          <form [formGroup]="legalRepresentative" class="formulario">
            <app-campo-texto [control]="legalRepresentative.controls.documentId" etiqueta="Nº documento" />
            <app-campo-texto [control]="legalRepresentative.controls.nombre" etiqueta="Nombre" />
            <app-campo-texto [control]="legalRepresentative.controls.primerApellido" etiqueta="Primer apellido" />
            <app-campo-texto [control]="legalRepresentative.controls.fechaNacimiento" etiqueta="Fecha de nacimiento" tipo="date" />
            <app-campo-select [control]="legalRepresentative.controls.sexo" etiqueta="Sexo" [opciones]="catalogos()['sexos'] ?? []" />
            <app-campo-texto [control]="legalRepresentative.controls.parentesco" etiqueta="Parentesco" />
          </form>
        }
      </app-seccion>
    </app-caja>
  </div>
  <div class="col-der">
    <app-caja titulo="Requisitos del tomador">
      @for (r of requisitos(); track r.etiqueta) {
        <div class="requisito" [class.hecho]="r.hecho" [class.pendiente]="!r.hecho">
          <mat-icon [class.ok]="r.hecho" [class.pendiente]="!r.hecho">{{ r.hecho ? 'check_circle' : 'radio_button_unchecked' }}</mat-icon>
          <span class="requisito-label">{{ r.etiqueta }}</span>
          <button
            mat-button
            type="button"
            class="realizar"
            [disabled]="r.hecho || !r.habilitado"
            [matTooltip]="r.hecho ? '' : 'Realizar ' + r.etiqueta"
            (click)="abrirRequisito(r.popup, r.etiqueta)">
            Realizar
          </button>
        </div>
      }
    </app-caja>
  </div>
</div>
`;

export const TOMADOR_STYLES = `
  .layout { display: grid; grid-template-columns: 2fr 1fr; gap: 16px; }
  @media (max-width: 900px) { .layout { grid-template-columns: 1fr; } }
  .formulario { display: grid; grid-template-columns: 1fr 1fr; gap: 12px 16px; padding: 0 16px 8px; }
  .col-der app-caja .requisitos { padding: 8px 16px 16px; }
  .requisito { display: flex; align-items: center; gap: 10px; padding: 8px 16px; border-bottom: 1px solid #eee; }
  .requisito:last-child { border-bottom: none; }
  .requisito mat-icon { font-size: 20px; width: 20px; height: 20px; }
  .requisito .ok { color: #2e7d32; }
  .requisito mat-icon.pendiente { color: var(--tva-primary, #d81e05); }
  .requisito.hecho .requisito-label { color: var(--tva-text, #212121); }
  .requisito.pendiente .requisito-label { color: #424242; }
  .requisito-label { flex: 1; font-size: 13px; }
  .requisito .realizar { font-size: 12px; color: var(--tva-primary, #d81e05); }
`;

@Component({
  selector: 'app-tomador1',
  imports: [
    ReactiveFormsModule,
    CajaComponent,
    SeccionComponent,
    CampoTextoComponent,
    CampoSelectComponent,
    MatCheckboxModule,
    MatSlideToggleModule,
    MatButtonModule,
    MatIconModule,
    MatTooltipModule,
  ],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: TOMADOR_TEMPLATE,
  styles: TOMADOR_STYLES,
})
export class CapturaTomador1Container extends TomadorBase {
  readonly cajaId = 'CAPTURA_DATOS_TOMADOR1';
  readonly indiceTomador = 0;
}
