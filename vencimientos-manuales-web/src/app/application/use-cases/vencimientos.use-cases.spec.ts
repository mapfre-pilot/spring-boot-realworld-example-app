import { TestBed } from '@angular/core/testing';
import { of } from 'rxjs';
import { BusquedaExpedientes } from '../../domain/models/api.models';
import {
  VENCIMIENTOS_REPOSITORY,
  VencimientosRepository,
} from '../ports/vencimientos.repository';
import { VencimientosUseCases } from './vencimientos.use-cases';

describe('VencimientosUseCases', () => {
  const repository = {
    searchExpedientes: jest.fn(),
  } as unknown as VencimientosRepository;

  beforeEach(() => {
    jest.clearAllMocks();
    (repository.searchExpedientes as jest.Mock).mockReturnValue(
      of({ content: [], page: 0, size: 20, totalElements: 0 })
    );
    TestBed.configureTestingModule({
      providers: [
        VencimientosUseCases,
        { provide: VENCIMIENTOS_REPOSITORY, useValue: repository },
      ],
    });
  });

  it('delega la búsqueda al repositorio de salida', () => {
    const criteria: BusquedaExpedientes = { anio: '2024', numero: '123' };
    const useCases = TestBed.inject(VencimientosUseCases);

    useCases.searchExpedientes(criteria);

    expect(repository.searchExpedientes).toHaveBeenCalledWith(criteria);
  });
});
