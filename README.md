# @capacitor-trancee/bluetooth-mesh

Bluetooth mesh network

## Install

```bash
npm install @capacitor-trancee/bluetooth-mesh
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
* [`addListener('onSend', ...)`](#addlisteneronsend-)
* [`addListener('onReceive', ...)`](#addlisteneronreceive-)
* [`addListener('onRSSI', ...)`](#addlisteneronrssi-)
* [`removeAllListeners()`](#removealllisteners)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize(...)

```typescript
initialize(options?: InitializeOptions | undefined) => Promise<void>
```

| Param         | Type                                                            |
| ------------- | --------------------------------------------------------------- |
| **`options`** | <code><a href="#initializeoptions">InitializeOptions</a></code> |

--------------------


### isInitialized()

```typescript
isInitialized() => Promise<IsInitializedResult>
```

**Returns:** <code>Promise&lt;<a href="#isinitializedresult">IsInitializedResult</a>&gt;</code>

--------------------


### start(...)

```typescript
start(options?: StartOptions | undefined) => Promise<void>
```

| Param         | Type                                                  |
| ------------- | ----------------------------------------------------- |
| **`options`** | <code><a href="#startoptions">StartOptions</a></code> |

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


### addListener('onSend', ...)

```typescript
addListener(eventName: 'onSend', listenerFunc: OnSendListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                      |
| ------------------ | --------------------------------------------------------- |
| **`eventName`**    | <code>'onSend'</code>                                     |
| **`listenerFunc`** | <code><a href="#onsendlistener">OnSendListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onReceive', ...)

```typescript
addListener(eventName: 'onReceive', listenerFunc: OnReceiveListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                            |
| ------------------ | --------------------------------------------------------------- |
| **`eventName`**    | <code>'onReceive'</code>                                        |
| **`listenerFunc`** | <code><a href="#onreceivelistener">OnReceiveListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### addListener('onRSSI', ...)

```typescript
addListener(eventName: 'onRSSI', listenerFunc: OnRSSIListener) => Promise<PluginListenerHandle>
```

| Param              | Type                                                      |
| ------------------ | --------------------------------------------------------- |
| **`eventName`**    | <code>'onRSSI'</code>                                     |
| **`listenerFunc`** | <code><a href="#onrssilistener">OnRSSIListener</a></code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### removeAllListeners()

```typescript
removeAllListeners() => Promise<void>
```

--------------------


### Interfaces


#### InitializeOptions


#### IsInitializedResult

| Prop                | Type                 |
| ------------------- | -------------------- |
| **`isInitialized`** | <code>boolean</code> |


#### StartOptions

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |


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

| Prop             | Type                                                        | Description                                                                                                                                                                                                                                                                                                                                                                                                   | Since |
| ---------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **`bluetooth`**  | <code><a href="#permissionstate">PermissionState</a></code> | `BLUETOOTH_ADVERTISE` Required to be able to advertise to nearby Bluetooth devices. `BLUETOOTH_CONNECT` Required to be able to connect to paired Bluetooth devices. `BLUETOOTH_SCAN` Required to be able to discover and pair nearby Bluetooth devices. `BLUETOOTH` Allows applications to connect to paired bluetooth devices. `BLUETOOTH_ADMIN` Allows applications to discover and pair bluetooth devices. | 1.0.0 |
| **`location`**   | <code><a href="#permissionstate">PermissionState</a></code> | `ACCESS_FINE_LOCATION` Allows an app to access precise location. ![Android](assets/android.svg) Only available for Android.                                                                                                                                                                                                                                                                                   | 1.0.0 |
| **`background`** | <code><a href="#permissionstate">PermissionState</a></code> | `ACCESS_BACKGROUND_LOCATION` Allows an app to access location in the background. ![Android](assets/android.svg) Only available for Android.                                                                                                                                                                                                                                                                   | 1.1.0 |


#### Permissions

| Prop              | Type                          |
| ----------------- | ----------------------------- |
| **`permissions`** | <code>PermissionType[]</code> |


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### OnStartedEvent


#### OnConnectedEvent

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |


#### OnDisconnectedEvent

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |


#### OnSendEvent

| Prop            | Type                                            |
| --------------- | ----------------------------------------------- |
| **`messageID`** | <code><a href="#messageid">MessageID</a></code> |


#### OnReceiveEvent

| Prop            | Type                                            |
| --------------- | ----------------------------------------------- |
| **`messageID`** | <code><a href="#messageid">MessageID</a></code> |
| **`data`**      | <code><a href="#base64">Base64</a></code>       |
| **`peerID`**    | <code><a href="#peerid">PeerID</a></code>       |


#### OnRSSIEvent

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`peerID`** | <code><a href="#peerid">PeerID</a></code> |
| **`rssi`**   | <code>number</code>                       |


### Type Aliases


#### PeerID

<code><a href="#id">ID</a></code>


#### ID

<code>string & { readonly __brand: unique symbol }</code>


#### MessageID

<code><a href="#uuid">UUID</a></code>


#### UUID

<code>string & { readonly __brand: unique symbol }</code>


#### Base64

<code>string & { readonly __brand: unique symbol }</code>


#### PermissionState

<code>'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'</code>


#### PermissionType

<code>'bluetooth' | 'location' | 'background'</code>


#### OnStartedListener

<code>(event: <a href="#onstartedevent">OnStartedEvent</a>): void</code>


#### OnStoppedListener

<code>(event: void): void</code>


#### OnConnectedListener

<code>(event: <a href="#onconnectedevent">OnConnectedEvent</a>): void</code>


#### OnDisconnectedListener

<code>(event: <a href="#ondisconnectedevent">OnDisconnectedEvent</a>): void</code>


#### OnSendListener

<code>(event: <a href="#onsendevent">OnSendEvent</a>): void</code>


#### OnReceiveListener

<code>(event: <a href="#onreceiveevent">OnReceiveEvent</a>): void</code>


#### OnRSSIListener

<code>(event: <a href="#onrssievent">OnRSSIEvent</a>): void</code>

</docgen-api>
