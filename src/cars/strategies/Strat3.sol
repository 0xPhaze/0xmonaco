// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.17;

// import "../Car.sol";
// import "futils/futils.sol";

// /// @dev only try optimizing acceleration
// ///      add in factor for when getting shelled
// contract Strat2 is Car {
//     string public name = "Strat2";

//     uint256 immutable accAmt;
//     uint256 immutable initialAccAmt;
//     uint256 immutable accBuyLimit;

//     constructor(Monaco _monaco, uint256, uint256 randomSeed) Car(_monaco) {
//         random.seed(randomSeed);

//         accAmt = random.next(1, 10);
//         shellAmt = random.next(1, 10);
//         initialAccAmt = random.next(1, 10);
//         accBuyLimit = random.next(1, 10) * 100;

//         console.log("\nparams");
//         console.log("initialAccAmt", initialAccAmt);
//         console.log("accAmt", accAmt);
//         console.log("accBuyLimit", accBuyLimit);
//     }

//     function takeYourTurn(Monaco.CarData[] calldata allCars, uint256 ourCarIndex) external override {
//         Monaco.CarData memory ourCar = allCars[ourCarIndex];

//         if (ourCar.speed <= 2) {
//             try monaco.buyAcceleration(initialAccAmt) {} catch (bytes memory) {}

//             return;
//         }

//         try monaco.buyAcceleration(accAmt) {} catch (bytes memory) {}
//     }
// }
