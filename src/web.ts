import { WebPlugin } from '@capacitor/core';

import type {
  ID,
  UUID,
  BitchatPlugin,
  InitializeOptions,
  InitializeResult,
  IsInitializedResult,
  StartOptions,
  StartResult,
  IsStartedResult,
  EstablishOptions,
  EstablishResult,
  IsEstablishedOptions,
  IsEstablishedResult,
  SendOptions,
  SendResult,
  PermissionStatus,
  Permissions,
} from './definitions';

let isInitialized = false;
let isStarted = false;
let isEstablished = false;
const peerID = getID();
let announceInterval = 30000; // 30 seconds
let announceIntervalTimeout: ReturnType<typeof setInterval>;

export class BitchatWeb extends WebPlugin implements BitchatPlugin {
  async initialize(options?: InitializeOptions): Promise<InitializeResult> {
    console.info('initialize', options ?? '');
    announceInterval = options?.announceInterval || 30000;
    isInitialized = true;
    this.notifyListeners('onPeerListUpdated', { peers: [peerID] });
    return { peerID };
  }
  async isInitialized(): Promise<IsInitializedResult> {
    console.info('isInitialized', { isInitialized });
    return { isInitialized };
  }

  async start(options?: StartOptions): Promise<StartResult> {
    console.info('start', options ?? '');
    if (!isInitialized) {
      throw new Error('not initialized');
    }
    isStarted = true;
    this.notifyListeners('onStarted', { peerID, isStarted });
    clearInterval(announceIntervalTimeout);
    announceIntervalTimeout = setInterval(() => {
      if (isStarted) {
        const message = options?.message;
        if (message) {
          const messageID = getUUID();
          this.notifyListeners('onSent', { messageID });
          this.notifyListeners('onReceived', { messageID, message });
        }
      }
    }, announceInterval);
    this.notifyListeners('onRSSIUpdated', { peerID, rssi: getRSSI() });
    return { peerID };
  }
  async isStarted(): Promise<IsStartedResult> {
    console.info('isStarted', { isStarted });
    return { isStarted };
  }

  async stop(): Promise<void> {
    console.info('stop');
    clearInterval(announceIntervalTimeout);
    isStarted = false;
    this.notifyListeners('onStopped', {});
  }

  async establish(options: EstablishOptions): Promise<EstablishResult> {
    console.info('establish', options);
    if (!isInitialized) {
      throw new Error('not initialized');
    }
    if (!isStarted) {
      throw new Error('not started');
    }
    const peerID = options.peerID;
    isEstablished = true;
    setTimeout(() => this.notifyListeners('onEstablished', { peerID }), 1000);
    return { isEstablished };
  }
  async isEstablished(options: IsEstablishedOptions): Promise<IsEstablishedResult> {
    console.info('isEstablished', options, { isEstablished });
    return { isEstablished };
  }

  async send(options: SendOptions): Promise<SendResult> {
    console.info('send', options);
    if (!isStarted) {
      throw new Error('not started');
    }
    const message = options.message;
    if (!message) {
      throw new Error('missing payload');
    }
    const messageID = getUUID();
    const recipientPeerID = options?.peerID;
    this.notifyListeners('onSent', { messageID, recipientPeerID });
    this.notifyListeners('onRSSIUpdated', { peerID, rssi: getRSSI() });
    options.peerID = recipientPeerID || peerID;
    this.notifyListeners('onReceived', { messageID, ...options });
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

function getID(): ID {
  return (Math.floor(Math.random() * 0xffffffff)
    .toString(16)
    .padEnd(8, '0') +
    Math.floor(Math.random() * 0xffffffff)
      .toString(16)
      .padEnd(8, '0')) as ID;
}
function getUUID(): UUID {
  return (Math.floor(Math.random() * 0xffffffff)
    .toString(16)
    .padEnd(8, '0') +
    '-' +
    Math.floor(Math.random() * 0xffff)
      .toString(16)
      .padEnd(4, '0') +
    '-' +
    Math.floor(Math.random() * 0xffff)
      .toString(16)
      .padEnd(4, '0') +
    '-' +
    Math.floor(Math.random() * 0xffff)
      .toString(16)
      .padEnd(4, '0') +
    '-' +
    Math.floor(Math.random() * 0xffffffffffff)
      .toString(16)
      .padEnd(12, '0')) as UUID;
}
function getRSSI(): number {
  return Math.floor(Math.random() * -100);
}
