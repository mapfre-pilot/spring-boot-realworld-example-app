import {
  esCifValido,
  esDocumentoIdentidadValido,
  esIbanValido,
  esNieValido,
  esNifValido,
} from './documentos';

describe('validaciones de documentos', () => {
  it('valida NIF con letra correcta', () => {
    expect(esNifValido('00000000T')).toBe(true);
    expect(esNifValido('00000000X')).toBe(false);
    expect(esNifValido('1234')).toBe(false);
  });

  it('valida NIE', () => {
    expect(esNieValido('X0000000T')).toBe(true);
    expect(esNieValido('X1234567M')).toBe(false);
  });

  it('valida CIF', () => {
    expect(esCifValido('A58818501')).toBe(true);
    expect(esCifValido('A58818502')).toBe(false);
  });

  it('documento genérico', () => {
    expect(esDocumentoIdentidadValido('00000000T')).toBe(true);
    expect(esDocumentoIdentidadValido('X0000000T')).toBe(true);
    expect(esDocumentoIdentidadValido('zzz')).toBe(false);
  });

  it('valida IBAN', () => {
    expect(esIbanValido('ES91 2100 0418 4502 0005 1332')).toBe(true);
    expect(esIbanValido('ES91 2100 0418 4502 0005 1333')).toBe(false);
    expect(esIbanValido('XX')).toBe(false);
  });
});
