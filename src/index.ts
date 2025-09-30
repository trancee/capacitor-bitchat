import { registerPlugin } from '@capacitor/core';

import type { BitchatPlugin } from './definitions';

const Bitchat = registerPlugin<BitchatPlugin>('Bitchat', {
  web: () => import('./web').then((m) => new m.BitchatWeb()),
});

export * from './definitions';
export { Bitchat };
