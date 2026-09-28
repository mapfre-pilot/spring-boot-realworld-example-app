/**
 * Validaciones de documentos — port de ``CMP_validacionDNI`` /
 * ``CMP_validacionNIE`` / ``CMP_validacionCIF`` y validación IBAN.
 */

const LETRAS_NIF = 'TRWAGMYFPDXBNJZSQVHLCKE';

export function esNifValido(nif: string): boolean {
  const m = /^(\d{8})([A-Za-z])$/.exec(nif.trim().toUpperCase());
  if (!m) return false;
  return LETRAS_NIF[Number(m[1]) % 23] === m[2];
}

export function esNieValido(nie: string): boolean {
  const m = /^([XYZ])(\d{7})([A-Za-z])$/.exec(nie.trim().toUpperCase());
  if (!m) return false;
  const num = { X: '0', Y: '1', Z: '2' }[m[1] as 'X' | 'Y' | 'Z'] + m[2];
  return LETRAS_NIF[Number(num) % 23] === m[3];
}

export function esCifValido(cif: string): boolean {
  const m = /^([ABCDEFGHJNPQRSUVW])(\d{7})([0-9AJ])$/.exec(cif.trim().toUpperCase());
  if (!m) return false;
  let suma = 0;
  for (let i = 0; i < 7; i++) {
    let d = Number(m[2][i]);
    if (i % 2 === 0) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    suma += d;
  }
  const control = (10 - (suma % 10)) % 10;
  const letra = 'JABCDEFGHI'[control];
  if ('PQSW'.includes(m[1])) return m[3] === letra;
  if ('ABEH'.includes(m[1])) return m[3] === String(control);
  return m[3] === letra || m[3] === String(control);
}

/** NIF, NIE o CIF válido. */
export function esDocumentoIdentidadValido(doc: string): boolean {
  const d = doc.trim().toUpperCase();
  return esNifValido(d) || esNieValido(d) || esCifValido(d);
}

export function esIbanValido(iban: string): boolean {
  const limpio = iban.replace(/\s/g, '').toUpperCase();
  if (!/^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$/.test(limpio)) return false;
  const reordenado = limpio.slice(4) + limpio.slice(0, 4);
  const digitos = reordenado
    .split('')
    .map(c => (/[A-Z]/.test(c) ? String(c.charCodeAt(0) - 55) : c))
    .join('');
  let resto = 0;
  for (const c of digitos) resto = (resto * 10 + Number(c)) % 97;
  return resto === 1;
}
