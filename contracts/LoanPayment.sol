// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LoanToken.sol";
import "./LoanContract.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract LoanPayment {
    using SafeERC20 for LoanToken;

    LoanToken public loanToken;
    LoanContract public loanContract;

    event PaymentMade(uint256 indexed loanId, address indexed payer, uint256 amount);

    modifier onlyActiveLoan(uint256 _loanId) {
        require(loanContract.loans[_loanId].active, "Loan not active");
        _;
    }

    constructor(address _loanTokenAddress, address _loanContractAddress) {
        loanToken = LoanToken(_loanTokenAddress);
        loanContract = LoanContract(_loanContractAddress);
    }

    function makePayment(uint256 _loanId, uint256 _amount) external onlyActiveLoan(_loanId) {
        require(loanToken.balanceOf(msg.sender) >= _amount, "Insufficient LoanTokens");

        loanToken.safeTransferFrom(msg.sender, address(this), _amount);

        uint256 equivalentAmount = calculateEquivalentAmount(_loanId, _amount);
        loanContract.loans(_loanId).borrower.transfer(equivalentAmount);

        emit PaymentMade(_loanId, msg.sender, _amount);
    }

    function calculateEquivalentAmount(uint256 _loanId, uint256 _loanTokenAmount)
        internal
        view
        returns (uint256)
    {
        uint256 interestRate = loanContract.loans(_loanId).interestRate;
        return (_loanTokenAmount * (100 + interestRate)) / 100;
    }
}
