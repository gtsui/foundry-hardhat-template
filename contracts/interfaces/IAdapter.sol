// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IAdapter {

  function swapExactTokensForETH(
                                 address payable recipient,
                                 address tokenTo,
                                 uint amountIn,
                                 uint amountOutMin,
                                 uint deadline,
                                 bytes memory data
                                 ) external;
  
  function swapExactETHForTokens(
                                 address recipient,
                                 address tokenTo,
                                 uint amountOutMin,
                                 uint deadline,
                                 bytes memory data
                                 ) external payable;
  
}
