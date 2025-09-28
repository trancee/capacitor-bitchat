import { BluetoothMesh } from '@capacitor-trancee/bluetooth-mesh';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    BluetoothMesh.echo({ value: inputValue })
}
