/** Factory del formulario de inicio TVA (validadores centralizados). */
import { FormArray, FormGroup, NonNullableFormBuilder, Validators } from '@angular/forms';

import { InicioRequest } from '../../domain/inicio.model';

export function crearFormularioInicio(fb: NonNullableFormBuilder) {
  return fb.group({
    indFunctionMode: ['VIA' as InicioRequest['indFunctionMode'], Validators.required],
    proposalId: [{ value: '', disabled: true }],
    companyId: ['0511'],
    numTomadores: [1],
    distributionChannel: ['500'],
    username: ['', Validators.required],
    tomador: [true],
    perfilado: [false],
    inversion: [true],
    investment: fb.array<FormGroup>([]),
  });
}

export function crearGrupoInversion(fb: NonNullableFormBuilder): FormGroup {
  return fb.group({
    commercialProductCode: [''],
    investmentPreferenceCode: [''],
    operationTypeCode: ['S'],
    policyId: [null],
    uniqueContributionAmn: [null],
    periodicContributionAmn: [null],
    contributionFrequencyCode: [null],
    insuranceOfferInd: [false],
  });
}

export type FormularioInicio = ReturnType<typeof crearFormularioInicio> & {
  controls: { investment: FormArray<FormGroup> };
};
