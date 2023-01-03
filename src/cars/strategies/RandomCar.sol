// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../Car.sol";
import "futils/futils.sol";

contract RandomCar is Car {
    constructor(Monaco _monaco, uint256 randomSeed) Car(_monaco) {
        random.seed(randomSeed);
    }

    function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
        Monaco.CarData memory ourCar = allCars[ourCarIndex];

        uint256 action = random.next(30);

        // console.log("action", action, ourCarIndex);

        if (action < 13) {
            uint256 amount = random.next(1, 10);

            if (ourCar.balance > monaco.getAccelerateCost(amount)) {
                ourCar.balance -= uint24(monaco.buyAcceleration(amount));
                // console.log("bought acc");
            }
        } else if (action < 26) {
            if (
                ourCar
                    // ourCarIndex != 0 && allCars[ourCarIndex - 1].speed > ourCar.speed
                    // &&
                    .balance > monaco.getShellCost(1)
            ) monaco.buyShell(1); // This will instantly set the car in front of us' speed to 1.
        }
    }
}
