//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import "hardhat/console.sol";

import "./IProduct.sol";

contract Product is IProduct {
 
  uint256 public rate;

  uint256 public depositEndTime;

  address public token;

  address public cashbox;

  address public factory;

  uint256 public rewardRate;

  address public owner;

  address public rewardToken;

  bytes4 private constant SELECTOR = bytes4(keccak256(bytes('timeSliceTransferFrom(address,address,uint256,uint256,uint256)')));

  bytes4 private constant SELECTOR1 = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
	
  uint256 public constant MAX_TIME = 18446744073709551615;

  mapping (address=> uint256) balanceOf;
  

  constructor(address _token,  uint256 _rate, uint256 _depositEndTime , address _cashbox, uint256 _rewardRate, address _rewardToken, address _owner ) public {
     rate = _rate;
     depositEndTime = _depositEndTime;
     token = _token;
     cashbox = _cashbox;
     rewardRate = _rewardRate;
     owner = _owner;
     rewardToken = _rewardToken;
  }

  function setRate(uint256 _rate) public override {
     require(msg.sender == owner, 'Product: Owner required');
      rate = _rate;
  }

  function setRewardRate(uint256 _rewardRate) public override {
    require(msg.sender == owner, 'Product: Owner required');
    rewardRate = _rewardRate;
  }

  function deposit(address from, uint256 amount) public override { 
     _safeTransfer(token, from, address(this), amount, block.timestamp, depositEndTime);

    uint256 day = (depositEndTime - block.timestamp) / (24 * 3600);
    
    amount = amount * (10 **18);
    uint256 interest = (amount * ((1 + rate)  ** day -1));
    uint256 _interest = interest / (10 **18);
    _safeTransfer(token, cashbox, from, _interest, depositEndTime, MAX_TIME);

    if(rewardRate !=0) {
      uint256 rewardAmount = (interest / rewardRate) / (10 **18);
       _mintReward(cashbox, from, rewardAmount);
    }
  }

  function _safeTransfer(address _token, address _from, address _to, uint value, uint256 tokenStart, uint256 tokenEnd) private {
      (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(SELECTOR, _from, _to, value, tokenStart, tokenEnd));
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: transfer failed');
  }

  function _mintReward(address _from, address _to, uint value) private {
    (bool success, bytes memory data) = rewardToken.call(abi.encodeWithSelector(SELECTOR1, _from, _to, value));
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: mint reward failed');
  }
}
