// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract WavePortal {
  uint256 totalWaves;
  uint256 private seed;

  event NewWave(address indexed from, uint256 timestamp, string message);

  struct Wave {
    address from;
    uint256 timestamp;
    string message;
  }

  Wave[] waves;
  mapping(address => uint256) public lastWavedAt;

  constructor() payable {
    console.log("WavePortal");

    seed = (block.timestamp + block.difficulty) % 100;
  }

  function wave(string memory _message) public {
    require(lastWavedAt[msg.sender] + 15 minutes <= block.timestamp, "Wait 15 minutes");

    lastWavedAt[msg.sender] = block.timestamp;

    totalWaves++;
    console.log("%s waved w/ message %s", msg.sender, _message);

    waves.push(Wave({
      from: msg.sender,
      timestamp: block.timestamp,
      message: _message
    }));

    seed = (block.timestamp + block.difficulty + seed) % 100;
    console.log("Random # generated: %d", seed);

    if (seed <= 50) {
      console.log("%s won!", msg.sender);

      uint256 prizeAmount = 0.001 ether;
      require(prizeAmount <= address(this).balance, "prize amount too high");
      (bool success, ) = (msg.sender).call{value: prizeAmount}("");
      require(success, "failed to withdraw money from contract");
    }

    emit NewWave(msg.sender, block.timestamp, _message);

  }

  function getAllWaves() public view returns (Wave[] memory) {
    return waves;
  }

  function getTotalWaves() public view returns (uint256) {
    console.log("Total waves: %s", totalWaves);
    return totalWaves;
  }
}