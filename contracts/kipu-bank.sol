// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title KipuBank
/// @notice Bovedas personales de ETH con límite por transaccion y tope global
contract KipuBank {
    /*//////////////////////////////////////////////////////////////
                               EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Se emite al depositar ETH.
    /// @param account Dirección del usuario que deposita.
    /// @param amount Monto depositado en wei.
    /// @param newBalance Nuevo saldo del usuario.
    event Deposit(address account, uint256 amount, uint256 newBalance);

    /// @notice Se emite al retirar ETH.
    /// @param account Direccion del usuario que retira.
    /// @param amount Monto retirado en wei.
    /// @param newBalance Nuevo saldo del usuario.
    event Withdraw(address account, uint256 amount, uint256 newBalance);

    /*//////////////////////////////////////////////////////////////
                               ERRORS
    /////////////////////////////////////////////////////////////*/

    /// @notice Monto debe ser > 0.
    error ZeroAmount();

    /// @notice Supera el tope global de depósitos.
    /// @param attempted Nuevo total intentado.
    /// @param cap Límite global.
    error DepositCapExceeded(uint256 attempted, uint256 cap);

    /// @notice Supera el límite por retiro.
    /// @param attempted Cantidad pedida.
    /// @param limit Límite por transacción.
    error WithdrawLimitExceeded(uint256 attempted, uint256 limit);

    /// @notice Saldo insuficiente.
    /// @param balance Saldo disponible.
    /// @param needed Cantidad pedida.
    error InsufficientBalance(uint256 balance, uint256  needed);

    /// @notice Falla en enviar ETH (llamada nativa).
    error EthTransferFailed();

    /*//////////////////////////// //////////////////////////////////
                          IMMUTABLES & STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Límite máximo por retiro (wei).
    uint256 public immutable withdrawLimit;


    /// @notice Tope global de depósitos (wei).
    uint256 public immutable bankCap;



    /// @notice Total depositado en el contrato.
    uint256 public totalDeposited;

    /// @notice Número total de depósitos.
    uint256 public depositCount;

    /// @notice Número total de retiros.
    uint256 public withdrawCount;

    /// @notice Saldos por usuario (bóveda personal).
    mapping(address => uint256) private balances;

    /*/////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _withdrawLimit Límite de retiro por transacción (wei).
    /// @param _bankCap Tope global de depósitos (wei).
    constructor(uint256 _withdrawLimit, uint256 _bankCap) {
        if (_withdrawLimit == 0 || _bankCap == 0) revert ZeroAmount();
        withdrawLimit = _withdrawLimit;
        bankCap = _bankCap;
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIER
    //////////////////////////////////////////////////////////////*/

    /// @notice Valida que el monto sea mayor que cero.
    /// @param amount Cantidad a validar (wei).
    modifier nonZero(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposita ETH en tu bóveda personal.
    function deposit() external payable nonZero(msg.value) {
        uint256 attempted = totalDeposited + msg.value;
        if (attempted > bankCap) revert DepositCapExceeded(attempted, bankCap);

        balances[msg.sender] += msg.value;
        totalDeposited = attempted;
        depositCount++;
        

        emit Deposit(msg.sender, msg.value, balances[msg.sender]);
    }

    /// @notice Retira ETH de tu bóveda personal.
    /// @param amount Monto a retirar (wei)
    function withdraw(uint256 amount) external nonZero(amount) {
        if (amount > withdrawLimit) revert WithdrawLimitExceeded(amount, withdrawLimit);

        uint256 bal = balances[msg.sender];
        if (bal < amount) revert InsufficientBalance(bal, amount);

        // Effects
        balances[msg.sender] = bal - amount;
        withdrawCount++;
        totalDeposited -= amount;
        

        // Interactions (transferencia nativa segura)
        (bool ok, ) = msg.sender.call{value: amount}("");
        if (!ok) revert EthTransferFailed();

        emit Withdraw(msg.sender, amount, balances[msg.sender]);
    }

    /// @notice Devuelve TU saldo en la bóveda.
    /// @return balance Saldo de quien llama a la funcion (wei).
    function getBalance() external view returns (uint256 balance) {
        return balances[msg.sender];
    }


    /// @param user Dirección a consultar.
    function _balanceOf(address user) private view returns (uint256) {
        return balances[user];
    }
}
