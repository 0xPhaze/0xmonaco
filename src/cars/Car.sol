// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Monaco.sol";

import "forge-std/console.sol";

abstract contract Car {
    Monaco public immutable monaco;

    constructor(Monaco _monaco) {
        monaco = _monaco;
    }

    // Note: The allCars array comes sorted in descending order of each car's y position.
    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 yourCarIndex) external virtual;
}
