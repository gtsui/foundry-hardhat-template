// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/UniswapV2/IUniswapV2Router02.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IZimaRouter.sol";

contract UniswapV2Adapter is IAdapter {

  using SafeERC20 for IERC20;

  IZimaRouter _zimaRouter;
  
  IUniswapV2Router02 _router;

  constructor(address zimaRouterAddr, address uniswapV2RouterAddr) {
    _zimaRouter = IZimaRouter(zimaRouterAddr);
    _router = IUniswapV2Router02(uniswapV2RouterAddr);    
  }

  receive() external payable{}

  modifier onlyZimaRouter() {
    require(msg.sender == address(_zimaRouter), "only zima router");
    _;
  }
  
  /** USER INTERFACE **/

  function swapExactTokensForETH(
                                 address payable recipient,
                                 address tokenFrom,
                                 uint amountIn,
                                 uint amountOutMin,
                                 uint deadline,
                                 bytes memory data
                                 ) external onlyZimaRouter {

    // shh
    data;

    // Build the path
    address[] memory path = new address[](2);
    path[0] = tokenFrom;
    path[1] = _zimaRouter.WETH();

    // Assume that ZimaRouter has already transferred `tokenFrom` funds
    // to this address. Approve the router to spend this.
    IERC20(tokenFrom).safeApprove(address(_router), amountIn);
    
    // Execute the swap
    _router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                                                               amountIn,
                                                               amountOutMin,
                                                               path,
                                                               address(this),
                                                               deadline
                                                               );

    // Collect the fee in ETH to `feeWallet` after executing swap
    _collectFee(recipient, address(this).balance);

    // Send the full balance of eth to user
    (bool sent, ) = recipient.call{value: address(this).balance}("");
    require(sent, "failed to send balance to user");
    
  }
  
  function swapExactETHForTokens(
                                 address recipient,
                                 address tokenTo,
                                 uint amountOutMin,
                                 uint deadline,
                                 bytes memory data
                                 ) external payable onlyZimaRouter {

    // shh
    data;
    
    // Store the full ETH amount sent by `recipient`
    uint amount = msg.value;
    
    // Collect the fee in ETH to `feeWallet` before executing swap
    _collectFee(recipient, amount);

    // Build the path
    address[] memory path = new address[](2);
    path[0] = _zimaRouter.WETH();
    path[1] = tokenTo;
    
    // Execute the swap
    _router.swapExactETHForTokensSupportingFeeOnTransferTokens{
    value: address(this).balance}(
                                  amountOutMin,
                                  path,
                                  recipient,
                                  deadline
                                  );
  }

  /** INTERNAL FUNCTIONS **/

  function _collectFee(address recipient, uint ethAmount) internal returns(uint) {
    uint feeBps = _zimaRouter.feeBps(recipient);
    uint fee = ethAmount * feeBps / 10000;
    address payable feeWallet = _zimaRouter.feeWallet();
    (bool sent, ) = feeWallet.call{value: fee}("");
    require(sent, "failed to collect fee");
    return ethAmount - fee;
  }  

  /// @notice Transfers token to sender if amount > 0
  /// @param token IERC20 token to transfer to sender
  /// @param amount Amount of token to transfer
  ///  @param recipient Address that will receive the tokens
  function _transfer(
                     IERC20 token,
                     uint256 amount,
                     address recipient
                     ) internal {
    if (amount > 0) {
      token.safeTransfer(recipient, amount);
    }
  }

}
