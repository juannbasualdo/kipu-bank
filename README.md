# KipuBank

KipuBank es un contrato inteligente simple que permite a los usuarios depositar y retirar Ether de una boveda personal.  Esta pensado para demostrar conceptos basicos de Solidity como variables de estado, funciones `payable`, eventos, errores personalizados y patrones de seguridad.


## Instrucciones de despliegue (Remix)

1. Abre Remix IDE(https://remix.ethereum.org/) en tu navegador.
2. Crea un nuevo archivo `KipuBank.sol` en tu espacio de trabajo y copia el contenido de `contracts/KipuBank.sol`.
3. En el panel de compilacion, selecciona un compilador de Solidity compatible (por ejemplo, `0.8.26`) y haz clic en Compile "KipuBank.sol".
4. En el panel de despliegue, selecciona el entorno "Injected Provider" y conecta tu wallet (por ejemplo, MetaMask) configurada con la red de pruebas Sepolia.
5. Indica dos parametros al desplegar:
   - `_withdrawLimit` : el monto maximo que un usuario puede retirar por operacion (en wei).
   - `_bankCap` : el limite global de Ether aceptado por el contrato (en wei).
6. Haz clic en "Deploy", firma la transaccion en tu wallet y espera a que se confirme.
7. En "Deployed Contracts", busca tu contrato y prueba las funciones:
   - `deposit()` : envia Ether a tu boveda marcando el campo "Value".
   - `withdraw(uint256 amount)` : retira fondos de tu boveda (hasta `withdrawLimit`).
   - `getBalance()` : consulta tu saldo.

## Interaccion con el contrato

- "Depositar Ether:" en Remix, selecciona tu contrato desplegado y, en la seccion `deposit`, especifica la cantidad de Ether en el campo `Value` (en Ether o unidades mas pequeñas). La transaccion debe emitirse con exito y se registrara un evento `Deposit`.
- "Retirar Ether:" en la funcion `withdraw`, introduce el monto a retirar (en wei) y ejecuta. Si tienes saldo suficiente y el monto es menor o igual a `withdrawLimit`, se realizara la transferencia y se registrara un evento `Withdraw`.
- "Consultar saldo:" utiliza `getBalance()` para ver cuanto Ether tienes almacenado.
