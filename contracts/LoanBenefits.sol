// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./LoanToken.sol";
import "./LoanContract.sol";

contract LoanBenefits {
    using SafeERC20 for LoanToken;

    LoanToken public loanToken;
    LoanContract public loanContract;

    uint256 public discountPercentage;
    address public governanceToken;

    event BenefitsClaimed(address indexed holder, uint256 amount, uint256 discount);

    modifier onlyLoanTokenHolder() {
        require(loanToken.balanceOf(msg.sender) > 0, "Not a LoanToken holder");
        _;
    }

    constructor(
        address _loanTokenAddress,
        address _loanContractAddress,
        uint256 _discountPercentage,
        address _governanceToken
    ) {
        loanToken = LoanToken(_loanTokenAddress);
        loanContract = LoanContract(_loanContractAddress);
        discountPercentage = _discountPercentage;
        governanceToken = _governanceToken;
    }

    function claimBenefits() external onlyLoanTokenHolder {
        uint256 loanTokenBalance = loanToken.balanceOf(msg.sender);
        uint256 discountAmount = (loanTokenBalance * discountPercentage) / 100;

        if (discountAmount > 0) {
            // Reducir la tasa de interés del préstamo actual
            uint256 currentLoanId = getCurrentLoanId(msg.sender);
            require(currentLoanId != type(uint256).max, "No active loans");

            loanContract.loans[currentLoanId].interestRate -= discountAmount;

            // Transferir beneficios al titular del LoanToken
            loanToken.safeTransfer(msg.sender, discountAmount);

            emit BenefitsClaimed(msg.sender, discountAmount, discountPercentage);
        }
    }

    function getCurrentLoanId(address _holder) internal view returns (uint256) {
        uint256 loansCount = loanContract.loans.length;

        for (uint256 i = 0; i < loansCount; i++) {
            if (loanContract.loans(i).borrower == _holder && loanContract.loans(i).active) {
                return i;
            }
        }

        return type(uint256).max; // Valor máximo de uint256 indica que no hay préstamos activos
    }
}
