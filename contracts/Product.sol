//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import "hardhat/console.sol";

import "./IProduct.sol";

contract Product is IProduct {
  uint256 public rate;
  uint256 public depositEndTime;
  address public token;
  address public cashbox;
  uint256 public rewardRate;
  address public owner;
  address public rewardToken;
  
  bytes4 private constant SLICE_SELECTOR = bytes4(keccak256(bytes('timeSliceTransferFrom(address,address,uint256,uint256,uint256)')));
  bytes4 private constant FULL_SELECTOR = bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

  uint256 public constant MAX_TIME = 18446744073709551615;

  mapping (address=> uint256) balanceOf;

  constructor(address _token,  uint256 _rate, uint256 _depositEndTime , address _cashbox, uint256 _rewardRate, address _rewardToken, address _owner ) {
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

  function deposit(uint256 amount) public override {
    //transfer token from user to this contract
    uint256 allowance = getAllowance(token, msg.sender, address(this));
    require(allowance >= amount, 'Product: Too less allowance for token');
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(FULL_SELECTOR, msg.sender, address(this), amount));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'Product: token transfer failed');
    
    //calculate interest
    uint256 day = (depositEndTime - block.timestamp) / (24 * 3600);
    uint256 interest = getInterest(day);
    uint256 interestAmount = interest * amount / (10**18);
    
     //transfer interest from cash box address to user
    uint256 allowance1 = getAllowance(token, cashbox, address(this));
    require(allowance1 >= interestAmount, 'Product: Too less allowance for interest');
    (bool success1, bytes memory data1) = token.call(abi.encodeWithSelector(SLICE_SELECTOR, cashbox, msg.sender, interestAmount, depositEndTime, MAX_TIME));
    require(success1 && (data1.length == 0 || abi.decode(data1, (bool))), 'Product: interest transfer failed');

    //calculate and transfer reward from cashbox to user, if supported
	uint256 rewardAmount = 0;
    if(rewardRate != 0) {
       rewardAmount = interestAmount / rewardRate * (10**18);
       if (rewardAmount > 0) {
            uint256 allowance2 = getAllowance(rewardToken, cashbox, address(this));
            require(allowance2 >= rewardAmount, 'Product: Too less allowance for reward');
            (bool success2, bytes memory data2) = rewardToken.call(abi.encodeWithSelector(FULL_SELECTOR, cashbox, msg.sender, rewardAmount));
            require(success2 && (data2.length == 0 || abi.decode(data2, (bool))), 'Product: reward transfer failed');   
       }
    }
  }

  function getInterest(uint256 day) internal view returns(uint256) {
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

  function getAllowance(address _token, address _owner, address _spender) private returns(uint256)  {
       uint256 allowance = 0;
       (bool success, bytes memory data) = _token.call(abi.encodeWithSelector(bytes4(keccak256(bytes('allowance(address,address)'))), _owner, _spender));
       if (success) {
            allowance = abi.decode(data, (uint256));
       }
       return allowance;
  }
}
