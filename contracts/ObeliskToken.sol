
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OBLSK is ERC20 {
    constructor() ERC20("OBLSK", "OBLSK") {
        _mint(msg.sender, 100000000 * 10**decimals()); // 100M tokens
    }
}
