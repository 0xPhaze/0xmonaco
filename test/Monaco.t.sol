// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";

import "../src/Monaco.sol";
import "../src/cars/ExampleCar.sol";

contract MonacoTest is Test {
    Monaco monaco;

    function setUp() public {
        monaco = new Monaco();
    }

    function testGames() public {
        Car w1 = new Car1(monaco);
        Car w2 = new Car2(monaco);
        Car w3 = new Car3(monaco);

        monaco.register(w1);
        monaco.register(w2);
        monaco.register(w3);

        // You can throw these CSV logs into Excel/Sheets/Numbers or a similar tool to visualize a race!
        vm.writeFile(string.concat("logs/", vm.toString(address(w1)), ".csv"), "turns,y,speed,balance\n");
        vm.writeFile(string.concat("logs/", vm.toString(address(w2)), ".csv"), "turns,y,speed,balance\n");
        vm.writeFile(string.concat("logs/", vm.toString(address(w3)), ".csv"), "turns,y,speed,balance\n");
        vm.writeFile("logs/prices.csv", "turns,accelerateCost,shellCost\n");
        vm.writeFile("logs/sold.csv", "turns,acceleratesBought,shellsBought\n");

        while (monaco.state() != Monaco.State.DONE) {
            monaco.play(1);

            // emit log("");

            Monaco.CarData[] memory allCarData = monaco.getAllCarData();

            for (uint256 i = 0; i < allCarData.length; i++) {
                Monaco.CarData memory car = allCarData[i];

                // emit log_address(address(car.car));
                // emit log_named_uint("y", car.y);
                // emit log_named_uint("speed", car.speed);
                // emit log_named_uint("balance", car.balance);

                vm.writeLine(
                    string.concat("logs/", vm.toString(address(car.car)), ".csv"),
                    string.concat(
                        vm.toString(uint256(monaco.turns())),
                        ",",
                        vm.toString(car.y),
                        ",",
                        vm.toString(car.speed),
                        ",",
                        vm.toString(car.balance)
                    )
                );

                vm.writeLine(
                    "logs/prices.csv",
                    string.concat(
                        vm.toString(uint256(monaco.turns())),
                        ",",
                        vm.toString(monaco.getAccelerateCost(1)),
                        ",",
                        vm.toString(monaco.getShellCost(1))
                    )
                );

                vm.writeLine(
                    "logs/sold.csv",
                    string.concat(
                        vm.toString(uint256(monaco.turns())),
                        ",",
                        vm.toString(monaco.getActionsSold(Monaco.ActionType.ACCELERATE)),
                        ",",
                        vm.toString(monaco.getActionsSold(Monaco.ActionType.SHELL))
                    )
                );
            }
        }

        emit log_named_uint("Number Of Turns", monaco.turns());

        string[] memory plotFFI = new string[](2);
        plotFFI[0] = "python3";
        plotFFI[1] = "plot.py";

        vm.ffi(plotFFI);
    }
}
