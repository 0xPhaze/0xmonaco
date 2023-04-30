// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "futils/futils.sol";

import "../src/Monaco.sol";

import {Strat2 as Car1} from "../src/cars/strategies/Strat2.sol";
import {Strat1 as Car2} from "../src/cars/strategies/Strat1.sol";
import {Strat1 as Car3} from "../src/cars/strategies/Strat1.sol";

function deployContractCode(bytes memory code) returns (address addr) {
    assembly {
        addr := create(0, add(code, 0x20), mload(code))
    }

    require(addr.code.length != 0, "Deployment failed.");
}

contract FoundryTestStub is TestBase {
    event log(string);
    event log_named_uint(string, uint256);
}

contract MonacoTest is Test {
    // contract MonacoTest is FoundryTestStub {
    using futils for *;

    Monaco monaco;

    uint256 raceId;

    Car[3] cars;
    mapping(uint256 => string) seeding;

    // log
    string logDir;
    bool enableLog;

    mapping(Car => string) logFile;

    function setUp() public {
        // enableLog = true;

        if (enableLog) vm.ffi(["find", "logs", "-name", "*.csv", "-delete"].toMemory());
    }

    uint256 seed = 122;

    function testMultiRace() public returns (uint256) {
        // function testMultiRace(uint256 seed) public returns (uint256) {
        // function echidna_testMultiRace() public returns (uint256) {
        uint256 bestScore = 6700;
        // uint256 bestScore = 3000;
        uint256 bestPlacing = 18;

        random.seed(seed);

        string[3] memory carEntry = [
            // Contracts
            // type(Car1).name,
            // type(Car2).name,
            // type(Car3).name
            "Strat2",
            // "Strat1",
            // "Strat1"
            // "Strat2",
            // "Strat2"
            // "ExampleCar",
            // "ExampleCar"
            "c000r",
            "c000r"
            // "Strat2",
            // "Strat2"
        ];

        // bytes[3] memory creationCodes = [type(Car1).creationCode, type(Car2).creationCode, type(Car3).creationCode];

        uint8[3][6] memory perms = [
            // permutations
            [0, 1, 2],
            [0, 2, 1],
            [1, 0, 2],
            [1, 2, 0],
            [2, 0, 1],
            [2, 1, 0]
        ];

        uint256[3] memory cumulativePlacings;
        uint256[3] memory cumulativeScores;

        uint256[3] memory r = [random.next(), random.next(), random.next()];

        for (uint256 i; i < 6; i++) {
            uint8[3] memory perm = perms[i];

            seeding[0] = carEntry[perm[0]];
            seeding[1] = carEntry[perm[1]];
            seeding[2] = carEntry[perm[2]];

            monaco = new Monaco();

            // cars[0] = Car(deployContractCode(abi.encodePacked(creationCodes[perm[0]], abi.encode(monaco, 0, r[0]))));
            // cars[1] = Car(deployContractCode(abi.encodePacked(creationCodes[perm[1]], abi.encode(monaco, 1, r[1]))));
            // cars[2] = Car(deployContractCode(abi.encodePacked(creationCodes[perm[2]], abi.encode(monaco, 2, r[2]))));

            cars[0] = Car(deployCode(string.concat(seeding[0], ".sol:", seeding[0]), abi.encode(monaco, 0, r[perm[0]])));
            cars[1] = Car(deployCode(string.concat(seeding[1], ".sol:", seeding[1]), abi.encode(monaco, 1, r[perm[1]])));
            cars[2] = Car(deployCode(string.concat(seeding[2], ".sol:", seeding[2]), abi.encode(monaco, 2, r[perm[2]])));

            uint256[3] memory placings = runRace();

            cumulativePlacings[perm[0]] += placings[0];
            cumulativePlacings[perm[1]] += placings[1];
            cumulativePlacings[perm[2]] += placings[2];

            cumulativeScores[perm[0]] += getScore(cars[0]);
            cumulativeScores[perm[1]] += getScore(cars[1]);
            cumulativeScores[perm[2]] += getScore(cars[2]);

            // console.log("\nRace %s\n======", i);
            // printAllCarData();
            // logPlacings();
        }

        emit log("\nCumulative Placings (6 races):");
        emit log_named_uint(carEntry[0], cumulativePlacings[0]);
        emit log_named_uint(carEntry[1], cumulativePlacings[1]);
        emit log_named_uint(carEntry[2], cumulativePlacings[2]);

        emit log("\nCumulative Scores:");
        emit log_named_uint(carEntry[0], cumulativeScores[0]);
        emit log_named_uint(carEntry[1], cumulativeScores[1]);
        emit log_named_uint(carEntry[2], cumulativeScores[2]);

        if (enableLog) vm.ffi(["python3", "plot.py"].toMemory());

        // if fuzz testing
        if (msg.data.length > 4) {
            console.log("final score", cumulativeScores[0]);

            if (bestScore != 0) assertTrue(cumulativeScores[0] < bestScore);
            if (bestPlacing != 0) assertTrue(cumulativePlacings[0] < bestPlacing);
        }

        return cumulativeScores[0];
    }

    function getScore(Car car) internal view returns (uint256 y) {
        (,, y,) = monaco.getCarData(car);

        if (monaco.getAllCarData()[0].car == car) y += 100;
    }

    function runRace() internal returns (uint256[3] memory placings) {
        // console.log(string.concat(seeding[0], ".sol:", seeding[0]));
        // console.log(string.concat(seeding[1], ".sol:", seeding[1]));
        // console.log(string.concat(seeding[2], ".sol:", seeding[2]));

        monaco.register(cars[0]);
        monaco.register(cars[1]);
        monaco.register(cars[2]);

        if (enableLog) {
            logDir = string.concat("logs/", vm.toString(uint256(raceId++)), "/");

            vm.ffi(["mkdir", "-p", logDir].toMemory());

            logFile[cars[0]] = string.concat(vm.toString(uint256(1)), "_", seeding[0]);
            logFile[cars[1]] = string.concat(vm.toString(uint256(2)), "_", seeding[1]);
            logFile[cars[2]] = string.concat(vm.toString(uint256(3)), "_", seeding[2]);

            vm.writeFile(string.concat(logDir, logFile[cars[0]], ".csv"), "turns,y,speed,balance\n");
            vm.writeFile(string.concat(logDir, logFile[cars[1]], ".csv"), "turns,y,speed,balance\n");
            vm.writeFile(string.concat(logDir, logFile[cars[2]], ".csv"), "turns,y,speed,balance\n");
            vm.writeFile(string.concat(logDir, "prices.csv"), "turns,accelerate,shell\n");
            vm.writeFile(string.concat(logDir, "sold.csv"), "turns,accelerate,shell\n");
        }

        while (monaco.state() != Monaco.State.DONE) {
            monaco.play(1);

            if (enableLog) logCarTurnData();
        }

        Monaco.CarData[] memory allCarData = monaco.getAllCarData();

        placings[carIndex(allCarData[0].car)] = 1;
        placings[carIndex(allCarData[1].car)] = 2;
        placings[carIndex(allCarData[2].car)] = 3;

        require(allCarData[0].y >= allCarData[1].y && allCarData[1].y >= allCarData[2].y, "invalid ordering");
    }

    function printAllCarData() internal view {
        Monaco.CarData[] memory allCarData = monaco.getAllCarData();

        for (uint256 j; j < 3; j++) {
            console.log("\n%s:", seeding[carIndex(allCarData[j].car)]);
            console.log("balance", allCarData[j].balance);
            console.log("speed", allCarData[j].speed);
            console.log("y", allCarData[j].y);
        }
    }

    function logCarTurnData() internal {
        Monaco.CarData[] memory allCarData = monaco.getAllCarData();

        for (uint256 i = 0; i < allCarData.length; i++) {
            Monaco.CarData memory car = allCarData[i];

            vm.writeLine(
                string.concat(logDir, logFile[car.car], ".csv"),
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
                string.concat(logDir, "prices.csv"),
                string.concat(
                    vm.toString(uint256(monaco.turns())),
                    ",",
                    vm.toString(monaco.getAccelerateCost(1)),
                    ",",
                    vm.toString(monaco.getShellCost(1))
                )
            );

            vm.writeLine(
                string.concat(logDir, "sold.csv"),
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

    // function runRaceAndLog() internal {
    //     // You can throw these CSV logs into Excel/Sheets/Numbers or a similar tool to visualize a race!

    function carIndex(Car car) internal view returns (uint256) {
        for (uint256 i; i < 3; ++i) {
            if (cars[i] == car) return i;
        }

        return type(uint256).max;
    }

    function getPlacings() internal view returns (uint256[3] memory placings) {
        Monaco.CarData[] memory allCarData = monaco.getAllCarData();

        placings[carIndex(allCarData[0].car)] = 1;
        placings[carIndex(allCarData[1].car)] = 2;
        placings[carIndex(allCarData[2].car)] = 3;
    }

    function logPlacings() internal {
        uint256[3] memory placings = getPlacings();

        emit log("\nPlacings:");
        emit log_named_uint(seeding[0], placings[0]);
        emit log_named_uint(seeding[1], placings[1]);
        emit log_named_uint(seeding[2], placings[2]);

        // emit log_named_uint("\nTurns", monaco.turns());
    }
}
