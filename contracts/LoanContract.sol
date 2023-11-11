// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LoanToken.sol";

contract LoanContract {
    // Dirección del contrato del token
    LoanToken public loanToken;

    // Estructura para almacenar información del préstamo
    struct Loan {
        address borrower;     // Dirección del prestatario
        uint256 amount;       // Monto del préstamo
        uint256 interestRate; // Tasa de interés del préstamo
        uint256 term;         // Plazo del préstamo en días
        uint256 startDate;    // Fecha de inicio del préstamo
        bool active;          // Estado del préstamo
    }

    // Array de préstamos
    Loan[] public loans;

    // Evento para notificar la emisión de un préstamo
    event LoanIssued(uint256 loanId, address indexed borrower, uint256 amount);

    // Modificador que requiere que el contrato esté activo
    modifier onlyActiveLoan(uint256 _loanId) {
        require(loans[_loanId].active, "Loan not active");
        _;
    }

    // Constructor que recibe la dirección del contrato del token
    constructor(address _loanTokenAddress) {
        loanToken = LoanToken(_loanTokenAddress);
    }

    // Función para emitir un préstamo
    function issueLoan(uint256 _amount, uint256 _interestRate, uint256 _term) external {
        // Verificar que el prestatario tenga suficientes tokens como garantía
        require(loanToken.balanceOf(msg.sender) >= _amount, "Insufficient collateral");

        // Transferir tokens como garantía al contrato
        loanToken.transferFrom(msg.sender, address(this), _amount);

        // Almacenar la información del préstamo en el array
        Loan memory newLoan = Loan({
            borrower: msg.sender,
            amount: _amount,
            interestRate: _interestRate,
            term: _term,
            startDate: block.timestamp,
            active: true
        });

        // Añadir el préstamo al array
        loans.push(newLoan);

        // Emitir el evento de emisión de préstamo
        emit LoanIssued(loans.length - 1, msg.sender, _amount);
    }

    // Función para consultar la información de un préstamo
    function getLoanInfo(uint256 _loanId)
        external
        view
        onlyActiveLoan(_loanId)
        returns (
            address borrower,
            uint256 amount,
            uint256 interestRate,
            uint256 term,
            uint256 startDate,
            bool active
        )
    {
        Loan memory loan = loans[_loanId];
        return (loan.borrower, loan.amount, loan.interestRate, loan.term, loan.startDate, loan.active);
    }
}
