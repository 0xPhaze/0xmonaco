// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Car.sol";

/// @dev only try optimizing acceleration
contract Strat1 is Car {
    string public name = "Strat1";

    constructor(Monaco _monaco) Car(_monaco) {}

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        uint256 accQuantity = 3;

        if (ourCar.balance > monaco.getAccelerateCost(accQuantity)) monaco.buyAcceleration(accQuantity);
    }
}
