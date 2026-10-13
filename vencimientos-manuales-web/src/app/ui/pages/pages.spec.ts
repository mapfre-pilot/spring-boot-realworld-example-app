import { Type } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { createComponentFactory } from '@ngneat/spectator/jest';
import { of } from 'rxjs';
import { VencimientosUseCases } from '../../application/use-cases/vencimientos.use-cases';
import { ExpedientesSearchPageComponent } from './expedientes-search-page.component';
import { ExpedienteManagementPageComponent } from './expediente-management-page.component';
import { VariablesPageComponent } from './variables-page.component';
import { FiniquitosPageComponent } from './finiquitos-page.component';
import { InformesPageComponent } from './informes-page.component';
import { BdgiPageComponent } from './bdgi-page.component';
import { ReaseguroPageComponent } from './reaseguro-page.component';
import { CarteraPolizaPageComponent } from './cartera-poliza-page.component';
import { CarterasPageComponent } from './carteras-page.component';
import { CargaFicheroPageComponent } from './carga-fichero-page.component';

type PageInstance = { form: FormGroup; submit(): void };

function mocks() {
  return {
    searchExpedientes: jest.fn(() =>
      of({ content: [], page: 0, size: 20, totalElements: 0 })
    ),
    createExpediente: jest.fn(() =>
      of({ anio: '2024', numero: '1', coaseguradoras: [] })
    ),
    saveVariables: jest.fn(() => of({})),
    getCoaseguro: jest.fn(() => of({ coaseguradoras: [] })),
    saveCoaseguro: jest.fn(() => of({ coaseguradoras: [] })),
    emitFiniquitos: jest.fn(() => of({ id: 'local' })),
    printInforme: jest.fn(() => of({ id: 'local' })),
    requestBdgi: jest.fn(() => of({ id: 'local' })),
    requestReaseguro: jest.fn(() => of(undefined)),
    getCartera: jest.fn(() =>
      of({ ramo: '001', anioPoliza: '2024', numeroPoliza: '1' })
    ),
    listCarteras: jest.fn(() =>
      of({ content: [], page: 0, size: 20, totalElements: 0 })
    ),
    uploadFile: jest.fn(() => of({ id: 'local' })),
  };
}

function pageTest(
  component: Type<PageInstance>,
  method: keyof ReturnType<typeof mocks>,
  fill: (page: PageInstance) => void
): void {
  describe(component.name, () => {
    const useCases = mocks();
    const createComponent = createComponentFactory({
      component,
      providers: [{ provide: VencimientosUseCases, useValue: useCases }],
    });

    beforeEach(() => jest.clearAllMocks());

    it('renderiza, valida la entrada y delega el caso de uso', () => {
      const spectator = createComponent();
      expect(spectator.query('h1')).toBeTruthy();
      spectator.component.submit();
      expect(useCases[method]).not.toHaveBeenCalled();

      fill(spectator.component);
      spectator.component.submit();
      expect(useCases[method]).toHaveBeenCalled();
    });
  });
}

pageTest(ExpedientesSearchPageComponent, 'searchExpedientes', (page) => {
  page.form.controls['anio'].setValue('2024');
  page.form.controls['numero'].setValue('123');
});

pageTest(ExpedienteManagementPageComponent, 'createExpediente', (page) => {
  page.form.controls['anio'].setValue('2024');
  page.form.controls['numero'].setValue('123');
});

describe('ExpedienteManagementPageComponent coaseguro', () => {
  const useCases = mocks();
  const createComponent = createComponentFactory({
    component: ExpedienteManagementPageComponent,
    providers: [{ provide: VencimientosUseCases, useValue: useCases }],
  });

  beforeEach(() => jest.clearAllMocks());

  it('no guarda porcentajes que no suman 100 y delega los válidos', () => {
    const spectator = createComponent();
    const page = spectator.component;
    page.form.controls['anio'].setValue('2024');
    page.form.controls['numero'].setValue('123');
    page.coaseguradoras.at(0).setValue({ codigo: 'A', porcentaje: 60 });
    page.coaseguradoras.at(1).setValue({ codigo: 'B', porcentaje: 30 });

    page.guardarCoaseguro();
    expect(useCases.saveCoaseguro).not.toHaveBeenCalled();

    page.coaseguradoras.at(1).patchValue({ porcentaje: 40 });
    page.guardarCoaseguro();
    expect(useCases.saveCoaseguro).toHaveBeenCalledWith('2024', '123', {
      coaseguradoras: [
        { codigo: 'A', porcentaje: 60 },
        { codigo: 'B', porcentaje: 40 },
      ],
    });
  });
});

pageTest(VariablesPageComponent, 'saveVariables', (page) => {
  page.form.controls['anio'].setValue('2024');
  page.form.controls['numero'].setValue('123');
  page.form.controls['codigo'].setValue('variable');
  page.form.controls['valor'].setValue('valor');
});

pageTest(FiniquitosPageComponent, 'emitFiniquitos', (page) => {
  page.form.controls['anio'].setValue('2024');
  page.form.controls['expedienteDesde'].setValue('123');
  page.form.controls['expedienteHasta'].setValue('456');
});

pageTest(InformesPageComponent, 'printInforme', (page) => {
  page.form.controls['tipoEmision'].setValue('01');
});

pageTest(BdgiPageComponent, 'requestBdgi', (page) => {
  page.form.controls['anioEjercicio'].setValue(2024);
  page.form.controls['mesEjercicio'].setValue(10);
  page.form.controls['fechaInicial'].setValue('2024-10-01');
  page.form.controls['fechaFinal'].setValue('2024-10-31');
});

pageTest(ReaseguroPageComponent, 'requestReaseguro', (page) => {
  page.form.controls['anio'].setValue('2024');
  page.form.controls['numero'].setValue('123');
});

pageTest(CarteraPolizaPageComponent, 'getCartera', (page) => {
  page.form.controls['ramo'].setValue('001');
  page.form.controls['anio'].setValue('2024');
  page.form.controls['numero'].setValue('123');
});

pageTest(CarterasPageComponent, 'listCarteras', (page) => {
  page.form.controls['page'].setValue(0);
  page.form.controls['size'].setValue(20);
});

pageTest(CargaFicheroPageComponent, 'uploadFile', (page) => {
  page.form.controls['tipoEmision'].setValue('01');
});
