// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Car.sol";

/// @dev only try optimizing acceleration
///      add in factor for when getting shelled
///      only buy when cheap
contract Strat3 is Car {
    constructor(Monaco _monaco) Car(_monaco) {}

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        uint256 shelledFactor = 5;
        uint256 quantity = 3;

        bool tooSlow = ourCar.speed <= 2;
        bool isCheap = monaco.getAccelerateCost(1) < 100;

        if (!isCheap && !tooSlow) return;

        if (tooSlow) quantity += shelledFactor;

        if (ourCar.balance > monaco.getAccelerateCost(quantity)) {
            ourCar.balance -= uint24(monaco.buyAcceleration(quantity));
        }
    }
}
