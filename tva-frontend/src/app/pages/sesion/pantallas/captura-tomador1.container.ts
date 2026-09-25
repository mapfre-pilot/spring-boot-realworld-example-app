/** CAPTURA_TOMADOR1: datos personales, domicilio y contacto del primer tomador. */
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { ReactiveFormsModule } from '@angular/forms';

import { CajaComponent } from '../../../shared/ui/caja.component';
import { CampoSelectComponent } from '../../../shared/ui/campo-select.component';
import { CampoTextoComponent } from '../../../shared/ui/campo-texto.component';
import { TomadorBase } from './tomador-base';

const TEMPLATE = `
  <app-caja titulo="Datos personales">
    <form [formGroup]="form" class="formulario">
      <app-campo-select [control]="form.controls.tipoDocumento" etiqueta="Tipo documento" [opciones]="tiposDocumento" />
      <app-campo-texto [control]="form.controls.documento" etiqueta="Nº documento" />
      <app-campo-texto [control]="form.controls.nombre" etiqueta="Nombre" />
      <app-campo-texto [control]="form.controls.apellido1" etiqueta="Primer apellido" />
      <app-campo-texto [control]="form.controls.apellido2" etiqueta="Segundo apellido" />
      <app-campo-texto [control]="form.controls.fechaNacimiento" etiqueta="Fecha de nacimiento" tipo="date" />
      <app-campo-select [control]="form.controls.sexo" etiqueta="Sexo" [opciones]="sexos" />
      <app-campo-select [control]="form.controls.estadoCivil" etiqueta="Estado civil" [opciones]="estadosCiviles" />
    </form>
  </app-caja>
  <app-caja titulo="Domicilio y contacto">
    <form [formGroup]="form" class="formulario">
      <app-campo-texto [control]="form.controls.tipoVia" etiqueta="Tipo de vía" />
      <app-campo-texto [control]="form.controls.direccion" etiqueta="Dirección" />
      <app-campo-texto [control]="form.controls.codigoPostal" etiqueta="Código postal" />
      <app-campo-texto [control]="form.controls.poblacion" etiqueta="Población" />
      <app-campo-texto [control]="form.controls.provincia" etiqueta="Provincia" />
      <app-campo-texto [control]="form.controls.telefono" etiqueta="Teléfono" />
      <app-campo-texto [control]="form.controls.email" etiqueta="Email" tipo="email" />
      <app-campo-texto [control]="form.controls.iban" etiqueta="IBAN" />
    </form>
  </app-caja>
  <app-caja titulo="Beneficiarios">
    <form [formGroup]="form" class="formulario">
      <app-campo-select [control]="form.controls.tipoBeneficiario" etiqueta="Tipo de beneficiario" [opciones]="tiposBeneficiario" />
      <app-campo-texto [control]="form.controls.beneficiarios" etiqueta="Detalle (personas o texto libre)" />
    </form>
  </app-caja>
`;

const STYLES = `.formulario { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }`;

@Component({
  selector: 'app-tomador1',
  imports: [ReactiveFormsModule, CajaComponent, CampoTextoComponent, CampoSelectComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: TEMPLATE,
  styles: STYLES,
})
export class CapturaTomador1Container extends TomadorBase {}
