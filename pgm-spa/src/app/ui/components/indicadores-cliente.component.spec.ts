import { createComponentFactory, Spectator } from '@ngneat/spectator/jest';
import { Cliente } from '../../domain/models/api.models';
import { IndicadoresClienteComponent } from './indicadores-cliente.component';

const base: Cliente = {
  id: 'C-1',
  nombre: 'Ana',
  apellidos: 'Pérez',
  tipoDocumento: 'NIF',
  documento: '00000000T',
  fechaNacimiento: '1980-01-01',
  nacionalidad: 'ES',
  tipologia: 'PARTICULAR',
  estado: 'EN_VIGOR',
  vip: true,
  robinson: false,
  exclusivoCorredor: false,
  direccion: {
    via: 'c/ Mayor',
    numero: '1',
    codigoPostal: '28001',
    localidad: 'Madrid',
    provincia: 'Madrid',
  },
  telefono: '600000000',
  email: 'a@b.es',
  oficinaGestora: 'OF-1',
  gestorAsignado: 'G',
  familia: [],
  alertas: [],
  palancas: {
    dniDigitalizado: true,
    rgpdFirmado: false,
    altaAci: false,
    clienteTotal: false,
    planPagos: false,
    enFamilia: true,
    dpv: false,
  },
  posicionBancaria: null,
  descuentoVinculacion: 10,
};

describe('IndicadoresClienteComponent', () => {
  let spectator: Spectator<IndicadoresClienteComponent>;
  const createComponent = createComponentFactory(IndicadoresClienteComponent);

  it('muestra estado, tipología, VIP, descuento de vinculación y palancas', () => {
    spectator = createComponent({ props: { c: base } });
    const texto = spectator.element.textContent ?? '';
    expect(texto).toContain('En vigor');
    expect(texto).toContain('Particular');
    expect(texto).toContain('VIP');
    expect(texto).toContain('Dto. vinculación 10%');
    expect(texto).toContain('✔ DNI');
    expect(texto).toContain('✘ RGPD');
    expect(texto).not.toContain('Robinson');
  });

  it('marca Robinson, exclusivo corredor, menor y potencial', () => {
    const hoy = new Date();
    spectator = createComponent({
      props: {
        c: {
          ...base,
          vip: false,
          robinson: true,
          exclusivoCorredor: true,
          estado: 'POTENCIAL',
          fechaNacimiento: `${hoy.getFullYear() - 10}-01-01`,
          descuentoVinculacion: null,
        },
      },
    });
    const texto = spectator.element.textContent ?? '';
    expect(texto).toContain('Potencial');
    expect(texto).toContain('Robinson');
    expect(texto).toContain('Exclusivo corredor');
    expect(texto).toContain('Menor');
    expect(texto).not.toContain('VIP');
  });
});
