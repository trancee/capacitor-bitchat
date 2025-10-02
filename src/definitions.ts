import type { PermissionState, PluginListenerHandle } from '@capacitor/core';

export type PeerID = ID;
export type MessageID = UUID;

export interface BitchatPlugin {
  initialize(options?: InitializeOptions): Promise<InitializeResult>;
  isInitialized(): Promise<IsInitializedResult>;

  start(options?: StartOptions): Promise<StartResult>;
  isStarted(): Promise<IsStartedResult>;
  stop(): Promise<void>;

  send(options: SendOptions): Promise<SendResult>;

  checkPermissions(): Promise<PermissionStatus>;
  requestPermissions(options?: Permissions): Promise<PermissionStatus>;

  addListener(eventName: 'onStarted', listenerFunc: OnStartedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onStopped', listenerFunc: OnStoppedListener): Promise<PluginListenerHandle>;

  addListener(eventName: 'onConnected', listenerFunc: OnConnectedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onDisconnected', listenerFunc: OnDisconnectedListener): Promise<PluginListenerHandle>;

  addListener(eventName: 'onSent', listenerFunc: OnSentListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onReceived', listenerFunc: OnReceivedListener): Promise<PluginListenerHandle>;

  addListener(eventName: 'onRSSIUpdated', listenerFunc: OnRSSIUpdatedListener): Promise<PluginListenerHandle>;
  addListener(eventName: 'onPeerListUpdated', listenerFunc: OnPeerListUpdatedListener): Promise<PluginListenerHandle>;

  removeAllListeners(): Promise<void>;
}

// eslint-disable-next-line @typescript-eslint/no-empty-interface
export interface InitializeOptions {}
export interface InitializeResult {
  /**
   * @since 0.1.1
   */
  peerID: PeerID;
}
export interface IsInitializedResult {
  isInitialized?: boolean;
}
export interface StartOptions {
  /**
   * @since 0.1.1
   */
  message?: Base64;
}
export interface StartResult {
  /**
   * @since 0.1.1
   */
  peerID: PeerID;
}
export interface IsStartedResult {
  isStarted?: boolean;
}
export interface SendOptions {
  message: Base64;
  peerID?: PeerID;
}
export interface SendResult {
  messageID: MessageID;
}

// Listeners

export type OnStartedListener = (event: OnStartedEvent) => void;
export interface OnStartedEvent {
  /**
   * @since 0.1.0
   */
  peerID: PeerID;
  /**
   * @since 0.1.1
   */
  isStarted?: boolean;
}
export type OnStoppedListener = (event: void) => void;
export type OnConnectedListener = (event: OnConnectedEvent) => void;
export interface OnConnectedEvent {
  peerID: PeerID;
}
export type OnDisconnectedListener = (event: OnDisconnectedEvent) => void;
export interface OnDisconnectedEvent {
  peerID: PeerID;
}
export type OnSentListener = (event: OnSentEvent) => void;
export interface OnSentEvent {
  messageID: MessageID;
  /**
   * @since 0.1.2
   */
  peerID?: PeerID;
}
export type OnReceivedListener = (event: OnReceivedEvent) => void;
export interface OnReceivedEvent {
  messageID?: MessageID;
  message: Base64;
  peerID?: PeerID;
}
export type OnRSSIUpdatedListener = (event: OnRSSIUpdatedEvent) => void;
export interface OnRSSIUpdatedEvent {
  peerID: PeerID;
  rssi: number;
}
export type OnPeerListUpdatedListener = (event: OnPeerListUpdatedEvent) => void;
export interface OnPeerListUpdatedEvent {
  /**
   * @since 0.1.1
   */
  peers: PeerID[];
}

// Permissions

export interface PermissionStatus {
  /**
   * `BLUETOOTH_ADVERTISE`  Required to be able to advertise to nearby Bluetooth devices.
   * `BLUETOOTH_CONNECT`  Required to be able to connect to paired Bluetooth devices.
   * `BLUETOOTH_SCAN`  Required to be able to discover and pair nearby Bluetooth devices.
   *
   * `BLUETOOTH`  Allows applications to connect to paired bluetooth devices.
   * `BLUETOOTH_ADMIN`  Allows applications to discover and pair bluetooth devices.
   *
   * @since 0.1.0
   */
  bluetooth?: PermissionState;
  /**
   * `ACCESS_FINE_LOCATION`  Allows an app to access precise location.
   * `ACCESS_COARSE_LOCATION`  Allows an app to access approximate location.
   *
   * ![Android](assets/android.svg) Only available for Android.
   *
   * @since 0.1.0
   */
  location?: PermissionState;
  /**
   * `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`  Allows an app to ignore battery optimizations.
   *
   * ![Android](assets/android.svg) Only available for Android.
   *
   * @since 0.1.0
   */
  battery?: PermissionState;
}
export type PermissionType = 'bluetooth' | 'location' | 'battery';
export interface Permissions {
  permissions?: PermissionType[];
}

// Helpers

export type ID = string & { readonly __brand: unique symbol };
export function isID(value: string): value is ID {
  return /^[0-9a-fA-F]{16}$/i.test(value);
}
export function ID(value: string): ID {
  return isID(value) ? (value as ID) : (undefined as never);
}

export type UUID = string & { readonly __brand: unique symbol };
export function isUUID(value: string): value is UUID {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(value);
}
export function UUID(value: string): UUID {
  return isUUID(value) ? (value as UUID) : (undefined as never);
}

export type Base64 = string & { readonly __brand: unique symbol };
export function isBase64(value: string): value is Base64 {
  return /^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(value);
}
export function Base64(value: string): Base64 {
  return isBase64(value) ? (value as Base64) : (undefined as never);
}
