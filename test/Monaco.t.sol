// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";

import "../src/Monaco.sol";

contract MonacoTest is Test {
    Monaco monaco;

    mapping(uint256 => string) entrants;
    mapping(Car => string) logFile;

    function setUp() public {
        monaco = new Monaco();

        string[] memory ffi = new string[](5);

        ffi[0] = "find";
        ffi[1] = "logs";
        ffi[2] = "-name";
        ffi[3] = "*.csv";
        ffi[4] = "-delete";

        vm.ffi(ffi);
    }

    function testRaceBaseline() public {
        entrants[1] = "ExampleCar";
        entrants[2] = "ClownCar";
        entrants[3] = "c000r";

        runRace();
    }

    function runRace() internal {
        Car w1 = Car(deployCode(string.concat(entrants[1], ".sol:", entrants[1]), abi.encode(monaco)));
        Car w2 = Car(deployCode(string.concat(entrants[2], ".sol:", entrants[2]), abi.encode(monaco)));
        Car w3 = Car(deployCode(string.concat(entrants[3], ".sol:", entrants[3]), abi.encode(monaco)));

        monaco.register(w1);
        monaco.register(w2);
        monaco.register(w3);

        logFile[w1] = string.concat(vm.toString(uint256(1)), "_", entrants[1]);
        logFile[w2] = string.concat(vm.toString(uint256(2)), "_", entrants[2]);
        logFile[w3] = string.concat(vm.toString(uint256(3)), "_", entrants[3]);

        // files

        // You can throw these CSV logs into Excel/Sheets/Numbers or a similar tool to visualize a race!
        vm.writeFile(string.concat("logs/", logFile[w1], ".csv"), "turns,y,speed,balance\n");
        vm.writeFile(string.concat("logs/", logFile[w2], ".csv"), "turns,y,speed,balance\n");
        vm.writeFile(string.concat("logs/", logFile[w3], ".csv"), "turns,y,speed,balance\n");
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
                    string.concat("logs/", logFile[car.car], ".csv"),
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

        string[] memory ffi = new string[](2);

        ffi[0] = "python3";
        ffi[1] = "plot.py";

        vm.ffi(ffi);
    }
}
