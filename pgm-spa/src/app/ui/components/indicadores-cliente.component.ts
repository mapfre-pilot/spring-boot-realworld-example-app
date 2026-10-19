import { Component, input } from '@angular/core';
import { Cliente } from '../../domain/models/api.models';

/** Indicadores y palancas de la ficha 360 (VIP, Robinson, exclusivo corredor, RGPD, DNI, ACI, Cliente Total…). */
@Component({
  selector: 'pgm-indicadores-cliente',
  template: `
    <div class="row">
      <span class="chip" [class.chip-ok]="c().estado === 'EN_VIGOR'" [class.chip-aviso]="c().estado === 'POTENCIAL'" [class.chip-error]="c().estado === 'ANULADO'">{{ etiquetaEstado[c().estado] }}</span>
      <span class="chip">{{ etiquetaTipologia[c().tipologia] }}</span>
      @if (c().vip) { <span class="chip chip-rojo">VIP</span> }
      @if (c().robinson) { <span class="chip chip-aviso">Robinson</span> }
      @if (c().exclusivoCorredor) { <span class="chip chip-aviso">Exclusivo corredor</span> }
      @if (esMenor()) { <span class="chip chip-aviso">Menor</span> }
      @if (c().descuentoVinculacion) { <span class="chip chip-ok">Dto. vinculación {{ c().descuentoVinculacion }}%</span> }
    </div>
    <div class="row palancas">
      @for (p of palancas; track p.clave) {
        <span class="chip" [class.chip-ok]="c().palancas[p.clave]" [class.chip-aviso]="!c().palancas[p.clave]" [title]="c().palancas[p.clave] ? p.si : p.no">
          {{ c().palancas[p.clave] ? '✔' : '✘' }} {{ p.texto }}
        </span>
      }
    </div>
  `,
  styles: `.palancas { margin-top: .5rem; }`,
})
export class IndicadoresClienteComponent {
  readonly c = input.required<Cliente>();
  readonly etiquetaEstado: Record<Cliente['estado'], string> = { EN_VIGOR: 'En vigor', POTENCIAL: 'Potencial', ANULADO: 'Anulado' };
  readonly etiquetaTipologia: Record<Cliente['tipologia'], string> = { PARTICULAR: 'Particular', AUTONOMO: 'Autónomo', EMPRESA: 'Empresa' };
  readonly palancas: { clave: keyof Cliente['palancas']; texto: string; si: string; no: string }[] = [
    { clave: 'dniDigitalizado', texto: 'DNI', si: 'DNI digitalizado', no: 'DNI pendiente de digitalizar' },
    { clave: 'rgpdFirmado', texto: 'RGPD', si: 'RGPD firmado', no: 'RGPD pendiente de firma' },
    { clave: 'altaAci', texto: 'ACI', si: 'Alta en ACI', no: 'Sin alta en ACI' },
    { clave: 'clienteTotal', texto: 'Cliente Total', si: 'Cliente Total', no: 'No es Cliente Total' },
    { clave: 'planPagos', texto: 'Plan de pagos', si: 'Con plan de pagos', no: 'Sin plan de pagos' },
    { clave: 'enFamilia', texto: 'En Familia', si: 'En Familia', no: 'Sin En Familia' },
    { clave: 'dpv', texto: 'DpV', si: 'Con DpV', no: 'Sin DpV' },
  ];

  esMenor(): boolean {
    const f = this.c().fechaNacimiento;
    if (!f) return false;
    const edad = (Date.now() - new Date(f).getTime()) / (365.25 * 24 * 3600 * 1000);
    return edad < 18;
  }
}
