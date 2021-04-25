//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.6;

import './Product.sol';
import './IProduct.sol';
// import "@nomiclabs/buidler/console.sol";

contract Factory{
    function create(address token, uint256 rate, uint256 depositEndTime, address cashbox ) public returns (address product) {
        bytes memory bytecode = type(Product).creationCode;
        assembly {
            product := create(0, add(bytecode, 32), mload(bytecode))
        }
        IProduct(product).initialize(token, rate, depositEndTime, cashbox);
    }
}