import { nuumaDe } from './nuuma';

describe('nuumaDe', () => {
  it('devuelve la parte local en mayúsculas', () => {
    expect(nuumaDe('operador1@mapfre.net')).toBe('OPERADOR1');
  });
  it('acepte null/undefined y sin arroba', () => {
    expect(nuumaDe(null)).toBe('');
    expect(nuumaDe(undefined)).toBe('');
    expect(nuumaDe('abc')).toBe('ABC');
  });
});
