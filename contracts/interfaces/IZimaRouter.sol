// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


interface IZimaRouter {

  event AddAdapter(uint adapterId, address adapter);
  event SetFeeWallet(address feeWallet);
  event Swap(
             address indexed account,
             address tokenFrom,
             uint amountFrom,
             address tokenTo,
             uint amountTo
             );
  
  /** ACCESS CONTROL FUNCTIONS **/
  
  function __setFeeWallet(address payable feeWallet_) external;
  function __addAdapter(uint adapterId, address adapterAddr) external;

  /** USER INTERFACE **/

  function swapExactTokensForETH(
                                 uint adapterId,
                                 address payable recipient,
                                 address tokenFrom,
                                 uint amountIn,
                                 uint amountOutMin,
                                 uint deadline,
                                 bytes memory data
                                 ) external;
  
  function swapExactETHForTokens(
                                 uint adapterId,
                                 address recipient,
                                 address tokenTo,
                                 uint amountOutMin,
                                 uint deadline,
                                 bytes memory data
                                 ) external payable;
  
  /** VIEW FUNCTIONS **/

  function WETH() external view returns(address);
  function feeBps(address user) external view returns(uint);
  function feeWallet() external view returns(address payable);
  
}
