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

  it('muestra estado, tipología y VIP', () => {
    spectator = createComponent({ props: { c: base } });
    const texto = spectator.element.textContent ?? '';
    expect(texto).toContain('Vigor');
    expect(texto).toContain('Particular');
    expect(texto).toContain('VIP');
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

  it('vista palancas: estado de DNI, RGPD, ACI, En Familia, plan de pagos, Cliente Total y DpV', () => {
    spectator = createComponent({ props: { c: base, vista: 'palancas' } });
    const palancas = spectator.queryAll('.palanca');
    expect(palancas).toHaveLength(7);
    const texto = spectator.element.textContent ?? '';
    expect(texto).toContain('Documentación digitalizada');
    expect(texto).toContain('RGPD no firmado');
    expect(texto).toContain('Sin alta en ACI');
    expect(spectator.queryAll('.palanca.activa')).toHaveLength(2);
  });
});
