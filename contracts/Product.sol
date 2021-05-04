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

     _safeTransfer(from, address(this), amount, block.timestamp, 666666666666);

    uint256 day = (depositEndTime - block.timestamp) / (24 * 3600);

    uint256 interest = getInterest(day, rate);

    uint256 interestAmount = interest * amount / (10**18);

    console.log('interestAmount', interest, interestAmount);

    _safeTransfer(cashbox, from, interestAmount, depositEndTime, MAX_TIME);

    if(rewardRate !=0) {
      uint256 rewardAmount = interestAmount / rewardRate * (10**18);
       console.log('rewardAmount', rewardAmount, cashbox, from);
       _mintReward(cashbox, from, rewardAmount);
    }
  }

  function getInterest(uint256 day, uint256 rate) internal returns(uint256)  {

      uint256 interest = 0;
      uint256 _days = day;
      uint256 min_day = 6;

      if(day <= 5) {
          min_day = day;
      }

      for(uint256 i = 2; i < min_day; i++) {
            uint256 ii = 1;
            for(uint256 j = i; j > 1; j--) {
                ii =  ii  * (j);
            }
            _days = _days * (day - i + 1);
            interest += _days / ii * (rate ** i) / (10 ** ((i-1)*18)); 
      }

      interest += day * rate;
      return interest;
  }

  function _safeTransfer(address _from, address _to, uint value, uint256 tokenStart, uint256 tokenEnd) private {
      (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, _from, _to, value, tokenStart, tokenEnd));
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: transfer failed');
  }

  function _mintReward(address _from, address _to, uint value) private {
    (bool success, bytes memory data) = rewardToken.call(abi.encodeWithSelector(SELECTOR, _from, _to, value , 0 , 66666666666));
      // console.log('reward', success);
      require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: mint reward failed');
  }
}
