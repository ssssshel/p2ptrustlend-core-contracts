// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LoanToken is ERC20 {
    constructor() ERC20("LoanToken", "LOAN") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}
