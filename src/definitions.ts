export interface BluetoothMeshPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
