import { WebPlugin } from '@capacitor/core';

import type {
  BluetoothMeshPlugin,
  InitializeOptions,
  IsInitializedResult,
  IsStartedResult,
  SendOptions,
  SendResult,
  StartOptions,
  PermissionStatus,
  Permissions,
} from './definitions';
import { UUID } from './definitions';

let isInitialized = false;
let isStarted = false;

export class BluetoothMeshWeb extends WebPlugin implements BluetoothMeshPlugin {
  async initialize(options?: InitializeOptions): Promise<void> {
    console.info('initialize', options ?? '');
    isInitialized = true;
  }
  async isInitialized(): Promise<IsInitializedResult> {
    console.info('isInitialized', { isInitialized });
    return { isInitialized };
  }

  async start(options?: StartOptions): Promise<void> {
    console.info('start', options ?? '');
    const peerID = options?.peerID || UUID('123e4567-e89b-12d3-a456-426614174000');
    isStarted = true;
    this.notifyListeners('onStarted', { peerID });
  }
  async isStarted(): Promise<IsStartedResult> {
    console.info('isStarted', { isStarted });
    return { isStarted };
  }

  async stop(): Promise<void> {
    console.info('stop');
    isStarted = false;
    this.notifyListeners('onStopped', {});
  }

  async send(options: SendOptions): Promise<SendResult> {
    console.info('send', options);
    const messageID = UUID('123e4567-e89b-12d3-a456-426614174000');
    this.notifyListeners('onSend', { messageID });
    this.notifyListeners('onReceive', { messageID, ...options });
    return { messageID };
  }

  async checkPermissions(): Promise<PermissionStatus> {
    console.info('checkPermissions');
    return {
      bluetooth: (await navigator.bluetooth.getAvailability()) ? 'prompt' : 'denied', // (await navigator.permissions.query({ name: 'bluetooth' })).state,
      location: (await navigator.permissions.query({ name: 'geolocation' })).state,
    };
  }
  async requestPermissions(options?: Permissions): Promise<PermissionStatus> {
    console.info('requestPermissions', options ?? '');
    const permissionStatus: PermissionStatus = {};
    if (options?.permissions?.includes('bluetooth')) {
      try {
        await navigator.bluetooth.requestDevice({ acceptAllDevices: true });
        permissionStatus.bluetooth = 'granted';
        // permissionStatus.bluetooth = (await navigator.bluetooth.requestLEScan({ acceptAllAdvertisements: true })).active
        //   ? 'granted'
        //   : 'denied';
      } catch {
        permissionStatus.bluetooth = 'denied';
      }
    }
    if (options?.permissions?.includes('location')) {
      permissionStatus.location = await new Promise((resolve) => {
        navigator.geolocation.getCurrentPosition(
          () => {
            resolve('granted');
          },
          () => {
            resolve('denied');
          },
        );
      });
    }
    return permissionStatus;
  }
}
