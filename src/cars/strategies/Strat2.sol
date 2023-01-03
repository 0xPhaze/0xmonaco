// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Car.sol";
import "futils/futils.sol";

/// @dev only try optimizing acceleration
///      add in factor for when getting shelled
contract Strat2 is Car {
    string public name = "Strat2";

    uint256 immutable accAmt;
    uint256 immutable initialAccAmt;
    uint256 immutable accBuyLimit;

    constructor(Monaco _monaco, uint256, uint256 randomSeed_) Car(_monaco) {
        random.seed(randomSeed_);

        initialAccAmt = random.next(1, 10);
        accAmt = random.next(1, 10);
        accBuyLimit = random.next(1, 1000);
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        if (monaco.turns() == 1) {
            monaco.buyAcceleration(initialAccAmt);

            return;
        }

        if (monaco.getAccelerateCost(accAmt) < accBuyLimit) ourCar.balance -= uint24(monaco.buyAcceleration(accAmt));

        // uint256 boostFactor = 6;

        // uint256 accAmt = 1;

        // if (ourCar.speed <= 1) accAmt *= boostFactor;

        // if (ourCar.balance > monaco.getAccelerateCost(accAmt)) {
        //     ourCar.balance -= uint24(monaco.buyAcceleration(accAmt));
        // }

        // if (
        //     ourCarIndex != 0 && allCars[ourCarIndex - 1].speed > ourCar.speed && ourCar.balance > monaco.getShellCost(1)
        // ) {
        //     monaco.buyShell(1); // This will instantly set the car in front of us' speed to 1.
        // }
    }
}
