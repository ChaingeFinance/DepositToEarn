//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

interface IProduct {
     function deposit(address from, uint256 amount) external;
     function setRate(uint256 _rate) external;
     function setRewardCHNG(uint256 _reward)external;
     function initialize(address _token,  uint256 _rate, uint256 _depositEndTime , address _cashbox, uint256 _rewardCHNG ) external;
}