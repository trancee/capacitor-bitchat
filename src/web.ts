import { WebPlugin } from '@capacitor/core';

import { ID, UUID } from './definitions';
import type {
  BitchatPlugin,
  InitializeOptions,
  IsInitializedResult,
  IsStartedResult,
  SendOptions,
  SendResult,
  StartOptions,
  PermissionStatus,
  Permissions,
} from './definitions';

let isInitialized = false;
let isStarted = false;

export class BitchatWeb extends WebPlugin implements BitchatPlugin {
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
    if (!isInitialized) {
      throw new Error('not initialized');
    }
    const peerID = ID('0011223344556677');
    isStarted = true;
    this.notifyListeners('onStarted', { peerID });
    this.notifyListeners('onRSSI', { peerID, rssi: -42 });
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
    if (!isStarted) {
      throw new Error('not started');
    }
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
      // battery: 'prompt',
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
    if (options?.permissions?.includes('battery')) {
      permissionStatus.battery = 'granted';
    }
    return permissionStatus;
  }
}
