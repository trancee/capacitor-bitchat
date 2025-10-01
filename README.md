# @capacitor-trancee/bitchat

<img width="256" height="256" alt="icon_128x128@2x" src="https://github.com/user-attachments/assets/90133f83-b4f6-41c6-aab9-25d0859d2a47" />

### Bluetooth Mesh Network (Offline)

- **Local Communication**: Direct peer-to-peer within Bluetooth range
- **Multi-hop Relay**: Messages route through nearby devices (max 7 hops)
- **No Internet Required**: Works completely offline in disaster scenarios
- **Noise Protocol Encryption**: End-to-end encryption with forward secrecy
- **Binary Protocol**: Compact packet format optimized for Bluetooth LE constraints
- **Automatic Discovery**: Peer discovery and connection management
- **Adaptive Power**: Battery-optimized duty cycling

https://github.com/permissionlesstech/bitchat
https://github.com/permissionlesstech/bitchat-android


## Install

```bash
npm install @capacitor-trancee/bitchat
npx cap sync
```

## API

<docgen-index>

* [`initialize(...)`](#initialize)
* [`isInitialized()`](#isinitialized)
* [`start(...)`](#start)
* [`isStarted()`](#isstarted)
* [`stop()`](#stop)
* [`send(...)`](#send)
* [`checkPermissions()`](#checkpermissions)
* [`requestPermissions(...)`](#requestpermissions)
* [`addListener('onStarted', ...)`](#addlisteneronstarted-)
* [`addListener('onStopped', ...)`](#addlisteneronstopped-)
* [`addListener('onConnected', ...)`](#addlisteneronconnected-)
* [`addListener('onDisconnected', ...)`](#addlistenerondisconnected-)
* [`addListener('onSent', ...)`](#addlisteneronsent-)
* [`addListener('onReceived', ...)`](#addlisteneronreceived-)
* [`addListener('onRSSIUpdated', ...)`](#addlisteneronrssiupdated-)
* [`addListener('onPeerListUpdated', ...)`](#addlisteneronpeerlistupdated-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options?: InitializeOptions | undefined) => Promise<InitializeResult>
```

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#initializeoptions">InitializeOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#initializeresult">InitializeResult</a>&gt;</code>

--------------------


### isInitialized()

```typescript
isInitialized() => Promise<IsInitializedResult>
```

**Returns:** <code>Promise&lt;<a href="#isinitializedresult">IsInitializedResult</a>&gt;</code>

--------------------


### start(...)

```typescript
start(options?: StartOptions | undefined) => Promise<StartResult>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#startoptions">StartOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#startresult">StartResult</a>&gt;</code>

--------------------


### isStarted()

```typescript
isStarted() => Promise<IsStartedResult>
```

**Returns:** <code>Promise&lt;<a href="#isstartedresult">IsStartedResult</a>&gt;</code>

--------------------


### stop()

```typescript
stop() => Promise<void>
```

--------------------


### send(...)

```typescript
send(options: SendOptions) => Promise<SendResult>
```

| Param         | Type                                                |
| ------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#sendoptions">SendOptions</a></code> |

**Returns:** <code>Promise&lt;<a href="#sendresult">SendResult</a>&gt;</code>

--------------------


### checkPermissions()

```typescript
checkPermissions() => Promise<PermissionStatus>
```

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

--------------------


### requestPermissions(...)

```typescript
requestPermissions(options?: Permissions | undefined) => Promise<PermissionStatus>
```

| Param         | Type                                                |
| ------------- | --------------------------------------------------- |
| **`options`** | <code><a href="#permissions">Permissions</a></code> |

**Returns:** <code>Promise&lt;<a href="#permissionstatus">PermissionStatus</a>&gt;</code>

--------------------


### addListener('onStarted', ...)

```typescript
addListener(eventName: 'onStarted', listenerFunc: OnStartedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                            |
| ------------------ | --------------------------------------------------------------- |
| **`eventName`**    | <code>'onStarted'</code>                                        |
| **`listenerFunc`** | <code><a href="#onstartedlistener">OnStartedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onStopped', ...)

```typescript
addListener(eventName: 'onStopped', listenerFunc: OnStoppedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                            |
| ------------------ | --------------------------------------------------------------- |
| **`eventName`**    | <code>'onStopped'</code>                                        |
| **`listenerFunc`** | <code><a href="#onstoppedlistener">OnStoppedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onConnected', ...)

```typescript
addListener(eventName: 'onConnected', listenerFunc: OnConnectedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                |
| ------------------ | ------------------------------------------------------------------- |
| **`eventName`**    | <code>'onConnected'</code>                                          |
| **`listenerFunc`** | <code><a href="#onconnectedlistener">OnConnectedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onDisconnected', ...)

```typescript
addListener(eventName: 'onDisconnected', listenerFunc: OnDisconnectedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                      |
| ------------------ | ------------------------------------------------------------------------- |
| **`eventName`**    | <code>'onDisconnected'</code>                                             |
| **`listenerFunc`** | <code><a href="#ondisconnectedlistener">OnDisconnectedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onSent', ...)

```typescript
addListener(eventName: 'onSent', listenerFunc: OnSentListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                      |
| ------------------ | --------------------------------------------------------- |
| **`eventName`**    | <code>'onSent'</code>                                     |
| **`listenerFunc`** | <code><a href="#onsentlistener">OnSentListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onReceived', ...)

```typescript
addListener(eventName: 'onReceived', listenerFunc: OnReceivedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                              |
| ------------------ | ----------------------------------------------------------------- |
| **`eventName`**    | <code>'onReceived'</code>                                         |
| **`listenerFunc`** | <code><a href="#onreceivedlistener">OnReceivedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onRSSIUpdated', ...)

```typescript
addListener(eventName: 'onRSSIUpdated', listenerFunc: OnRSSIUpdatedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                    |
| ------------------ | ----------------------------------------------------------------------- |
| **`eventName`**    | <code>'onRSSIUpdated'</code>                                            |
| **`listenerFunc`** | <code><a href="#onrssiupdatedlistener">OnRSSIUpdatedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onPeerListUpdated', ...)

```typescript
addListener(eventName: 'onPeerListUpdated', listenerFunc: OnPeerListUpdatedListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                            |
| ------------------ | ------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'onPeerListUpdated'</code>                                                |
| **`listenerFunc`** | <code><a href="#onpeerlistupdatedlistener">OnPeerListUpdatedListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### Interfaces


#### InitializeResult

| Prop         | Type                                      | Since |
| ------------ | ----------------------------------------- | ----- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> | 0.1.1 |


#### InitializeOptions


#### IsInitializedResult

| Prop                | Type                 |
| ------------------- | -------------------- |
| **`isInitialized`** | <code>boolean</code> |


#### StartResult

| Prop         | Type                                      | Since |
| ------------ | ----------------------------------------- | ----- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> | 0.1.1 |


#### StartOptions

| Prop       | Type                                      | Since |
| ---------- | ----------------------------------------- | ----- |
| **`data`** | <code><a href="#base64">Base64</a></code> | 0.1.1 |


#### IsStartedResult

| Prop            | Type                 |
| --------------- | -------------------- |
| **`isStarted`** | <code>boolean</code> |


#### SendResult

| Prop            | Type                                            |
| --------------- | ----------------------------------------------- |
| **`messageID`** | <code><a href="#messageid">MessageID</a></code> |


#### SendOptions

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`data`**   | <code><a href="#base64">Base64</a></code> |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |


#### PermissionStatus

| Prop            | Type                                                        | Description                                                                                                                                                                                                                                                                                                                                                                                                   | Since |
| --------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **`bluetooth`** | <code><a href="#permissionstate">PermissionState</a></code> | `BLUETOOTH_ADVERTISE` Required to be able to advertise to nearby Bluetooth devices. `BLUETOOTH_CONNECT` Required to be able to connect to paired Bluetooth devices. `BLUETOOTH_SCAN` Required to be able to discover and pair nearby Bluetooth devices. `BLUETOOTH` Allows applications to connect to paired bluetooth devices. `BLUETOOTH_ADMIN` Allows applications to discover and pair bluetooth devices. | 0.1.0 |
| **`location`**  | <code><a href="#permissionstate">PermissionState</a></code> | `ACCESS_FINE_LOCATION` Allows an app to access precise location. `ACCESS_COARSE_LOCATION` Allows an app to access approximate location. ![Android](assets/android.svg) Only available for Android.                                                                                                                                                                                                            | 0.1.0 |
| **`battery`**   | <code><a href="#permissionstate">PermissionState</a></code> | `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` Allows an app to ignore battery optimizations. ![Android](assets/android.svg) Only available for Android.                                                                                                                                                                                                                                                              | 0.1.0 |


#### Permissions

| Prop              | Type                          |
| ----------------- | ----------------------------- |
| **`permissions`** | <code>PermissionType[]</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### OnStartedEvent

| Prop            | Type                                      | Since |
| --------------- | ----------------------------------------- | ----- |
| **`peerID`**    | <code><a href="#peerid">PeerID</a></code> | 0.1.0 |
| **`isStarted`** | <code>boolean</code>                      | 0.1.1 |


#### OnConnectedEvent

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |


#### OnDisconnectedEvent

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |


#### OnSentEvent

| Prop            | Type                                            | Since |
| --------------- | ----------------------------------------------- | ----- |
| **`messageID`** | <code><a href="#messageid">MessageID</a></code> |       |
| **`peerID`**    | <code><a href="#peerid">PeerID</a></code>       | 0.1.2 |


#### OnReceivedEvent

| Prop            | Type                                            |
| --------------- | ----------------------------------------------- |
| **`messageID`** | <code><a href="#messageid">MessageID</a></code> |
| **`data`**      | <code><a href="#base64">Base64</a></code>       |
| **`peerID`**    | <code><a href="#peerid">PeerID</a></code>       |


#### OnRSSIUpdatedEvent

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |
| **`rssi`**   | <code>number</code>                       |


#### OnPeerListUpdatedEvent

| Prop        | Type              | Since |
| ----------- | ----------------- | ----- |
| **`peers`** | <code>ID[]</code> | 0.1.1 |


### Type Aliases


#### PeerID

<code><a href="#id">ID</a></code>


#### ID

<code>string & { readonly __brand: unique symbol }</code>


#### Base64

<code>string & { readonly __brand: unique symbol }</code>


#### MessageID

<code><a href="#uuid">UUID</a></code>


#### UUID

<code>string & { readonly __brand: unique symbol }</code>


#### PermissionState

<code>'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'</code>


#### PermissionType

<code>'bluetooth' | 'location' | 'battery'</code>


#### OnStartedListener

<code>(event: <a href="#onstartedevent">OnStartedEvent</a>): void</code>


#### OnStoppedListener

<code>(event: void): void</code>


#### OnConnectedListener

<code>(event: <a href="#onconnectedevent">OnConnectedEvent</a>): void</code>


#### OnDisconnectedListener

<code>(event: <a href="#ondisconnectedevent">OnDisconnectedEvent</a>): void</code>


#### OnSentListener

<code>(event: <a href="#onsentevent">OnSentEvent</a>): void</code>


#### OnReceivedListener

<code>(event: <a href="#onreceivedevent">OnReceivedEvent</a>): void</code>


#### OnRSSIUpdatedListener

<code>(event: <a href="#onrssiupdatedevent">OnRSSIUpdatedEvent</a>): void</code>


#### OnPeerListUpdatedListener

<code>(event: <a href="#onpeerlistupdatedevent">OnPeerListUpdatedEvent</a>): void</code>

</docgen-api>
