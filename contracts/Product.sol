//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import "hardhat/console.sol";

import "./IProduct.sol";

contract Product is IProduct {
 
  uint256 public rate; // 利率 如果是 

  uint256 public depositEndTime;

  address public token;

  address public cashbox;

  address public factory;

  uint256 public rewardCHNG;

  address public owner;

  bytes4 private constant SELECTOR = bytes4(keccak256(bytes('timeSliceTransferFrom(address,address,uint256,uint256,uint256)')));

  bytes4 private constant SELECTOR1 = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
	uint256 public constant MAX_TIME = 18446744073709551615;

  mapping (address=> uint256) balanceOf;
  
  constructor() public {
      factory = msg.sender;
  }

  function initialize(address _token,  uint256 _rate, uint256 _depositEndTime , address _cashbox, uint256 _rewardCHNG, address _owner ) public override {
     rate = _rate;
     depositEndTime = _depositEndTime;
     token = _token;
     cashbox = _cashbox;
     rewardCHNG = _rewardCHNG;
     owner = _owner;
  }

  function setRate(uint256 _rate) public override {
     require(msg.sender == owner);
      rate = _rate;
  }

  function setRewardCHNG(uint256 _reward) public override {
    require(msg.sender == owner);
    rewardCHNG = _reward;
  }

  function deposit(address from, uint256 amount) public override { // 接收充值的函数，用户将前段币转入次合约，合约将利息发放给用户。
     _safeTransfer(token, from, address(this), amount, block.timestamp, depositEndTime); // 钱转入合约

    uint256 day = depositEndTime - block.timestamp / (24 * 3600);
    // 合约为 用户发放收益
    uint256 interest = amount * ((1 + rate)  ** day -1) ;
    _safeTransfer(token, cashbox, from, interest, depositEndTime, MAX_TIME);

    // 发放chng
    if(rewardCHNG !=0) {
      uint256 rewardAmount = interest / rewardCHNG;
       _mintChng(cashbox, from, rewardAmount);
    }
  }

  function _safeTransfer(address _token, address _from, address _to, uint value, uint256 tokenStart, uint256 tokenEnd) private {
      (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(SELECTOR, _from, _to, value, tokenStart, tokenEnd));
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: TRANSFER_FAILED');
  }

  function _mintChng(address from, address _from, address _to, uint value) private {
    address chngToken = '';
    (bool success, bytes memory data) = chngToken.call(abi.encodeWithSelector(SELECTOR, _from, _to, value));
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: mintChng_FAILED');
  }
}
