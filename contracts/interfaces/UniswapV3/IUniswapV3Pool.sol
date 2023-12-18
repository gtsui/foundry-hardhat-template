// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

interface IUniswapV3Pool {

  function liquidity() external view returns(uint128);
  function fee() external view returns(uint24);
}
