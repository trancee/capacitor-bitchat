import { WebPlugin } from '@capacitor/core';

import type { BluetoothMeshPlugin } from './definitions';

export class BluetoothMeshWeb extends WebPlugin implements BluetoothMeshPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
