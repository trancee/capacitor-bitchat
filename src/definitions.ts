import type { PermissionState, PluginListenerHandle } from '@capacitor/core';

export type PeerID = UUID;
export type MessageID = UUID;

export interface BluetoothMeshPlugin {
  initialize(options?: InitializeOptions): Promise<void>;
  isInitialized(): Promise<IsInitializedResult>;

  start(options?: StartOptions): Promise<void>;
  isStarted(): Promise<IsStartedResult>;
  stop(): Promise<void>;

  send(options: SendOptions): Promise<SendResult>;

  checkPermissions(): Promise<PermissionStatus>;
  requestPermissions(options?: Permissions): Promise<PermissionStatus>;

  addListener(eventName: 'onStarted', listenerFunc: OnStartedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onStopped', listenerFunc: OnStoppedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onConnected', listenerFunc: OnConnectedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onDisconnected', listenerFunc: OnDisconnectedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onSend', listenerFunc: OnSendListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onReceive', listenerFunc: OnReceiveListener): Promise<PluginListenerHandle>;

  removeAllListeners(): Promise<void>;
}

// eslint-disable-next-line @typescript-eslint/no-empty-interface
export interface InitializeOptions {}
export interface IsInitializedResult {
  isInitialized?: boolean;
}
// eslint-disable-next-line @typescript-eslint/no-empty-interface
export interface StartOptions {
  peerID?: PeerID;
}
export interface IsStartedResult {
  isStarted?: boolean;
}
export interface SendOptions {
  data: Base64;
  peerID?: PeerID;
}
export interface SendResult {
  messageID: MessageID;
}

export interface PermissionStatus {
  /**
   * `BLUETOOTH_ADVERTISE`  Required to be able to advertise to nearby Bluetooth devices.
   * `BLUETOOTH_CONNECT`  Required to be able to connect to paired Bluetooth devices.
   * `BLUETOOTH_SCAN`  Required to be able to discover and pair nearby Bluetooth devices.
   *
   * `BLUETOOTH`  Allows applications to connect to paired bluetooth devices.
   * `BLUETOOTH_ADMIN`  Allows applications to discover and pair bluetooth devices.
   *
   * @since 1.0.0
   */
  bluetooth?: PermissionState;
  /**
   * `ACCESS_FINE_LOCATION`  Allows an app to access precise location.
   *
   * ![Android](assets/android.svg) Only available for Android.
   *
   * @since 1.0.0
   */
  location?: PermissionState;
  /**
   * `ACCESS_BACKGROUND_LOCATION`  Allows an app to access location in the background.
   *
   * ![Android](assets/android.svg) Only available for Android.
   *
   * @since 1.1.0
   */
  background?: PermissionState;
}
export type PermissionType = 'bluetooth' | 'location' | 'background';
export interface Permissions {
  permissions?: PermissionType[];
}

export type OnStartedListener = (event: OnStartedEvent) => void;
// eslint-disable-next-line @typescript-eslint/no-empty-interface
export interface OnStartedEvent {}
export type OnStoppedListener = (event: void) => void;
export type OnConnectedListener = (event: OnConnectedEvent) => void;
export interface OnConnectedEvent {
  peerID: PeerID;
}
export type OnDisconnectedListener = (event: OnDisconnectedEvent) => void;
export interface OnDisconnectedEvent {
  peerID: PeerID;
}
export type OnSendListener = (event: OnSendEvent) => void;
export interface OnSendEvent {
  messageID: MessageID;
}
export type OnReceiveListener = (event: OnReceiveEvent) => void;
export interface OnReceiveEvent {
  messageID: MessageID;
  data: Base64;
  peerID?: PeerID;
}

// Helpers

export type Base64 = string & { readonly __brand: unique symbol };
export function isBase64(value: string): value is Base64 {
  return /^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(value);
}
export function Base64(value: string): Base64 {
  return isBase64(value) ? (value as Base64) : (undefined as never);
}

export type UUID = string & { readonly __brand: unique symbol };
export function isUUID(value: string): value is UUID {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}
export function UUID(value: string): UUID {
  return isUUID(value) ? (value as UUID) : (undefined as never);
}
