import { MatButtonModule } from '@angular/material/button';

import { MATERIAL } from './material';

describe('MATERIAL', () => {
  it('agrupa los módulos Material compartidos', () => {
    expect(MATERIAL).toHaveLength(10);
    expect(MATERIAL).toContain(MatButtonModule);
  });
});
