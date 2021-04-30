//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

interface IProduct {
     function deposit(address from, uint256 amount) external;
     function setRate(uint256 _rate) external;
     function setRewardRate(uint256 _reward)external;
}