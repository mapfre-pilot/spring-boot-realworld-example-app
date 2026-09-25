/** NUUMA = parte local del correo en mayúsculas. */
export function nuumaDe(username: string | null | undefined): string {
  return (username ?? '').split('@')[0].toUpperCase();
}
