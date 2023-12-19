// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/UniswapV3/ISwapRouter.sol";
import "./interfaces/UniswapV3/IUniswapV3Factory.sol";
import "./interfaces/UniswapV3/IUniswapV3Pool.sol";
import "./interfaces/IWETH/IWeth.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IZimaRouter.sol";

contract UniswapV3Adapter is IAdapter {

  using SafeERC20 for IERC20;

  IZimaRouter _zimaRouter;
  ISwapRouter _router;
  IUniswapV3Factory _factory;
    
  constructor(address zimaRouterAddr, address uniswapV3FactoryAddr, address swapRouterAddr) {
    _zimaRouter = IZimaRouter(zimaRouterAddr);
    _factory = IUniswapV3Factory(uniswapV3FactoryAddr);
    _router = ISwapRouter(swapRouterAddr);
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
   
    // Assume that ZimaRouter has already transferred `tokenFrom` funds
    // to this address. Approve the router to spend this.
    IERC20(tokenFrom).safeApprove(address(_router), amountIn);

    // Deserialize the pool address to retrieve fee
    (address poolAddr) = abi.decode(data, (address));
    uint24 fee = IUniswapV3Pool(poolAddr).fee();
    
    // Build the params
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: tokenFrom,
      tokenOut: _zimaRouter.WETH(),
      fee: fee,
      recipient: address(this),
      deadline: deadline,
      amountIn: amountIn,
      amountOutMinimum: amountOutMin,
      sqrtPriceLimitX96: 0
      });

    // Execute the swap
    _router.exactInputSingle(params);

    // Uniwrap WETH to ETH
    IWETH WETH = IWETH(_zimaRouter.WETH());
    WETH.withdraw(WETH.balanceOf(address(this)));

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
    
    // Store the full ETH amount sent by `recipient`
    uint amount = msg.value;
    
    // Collect the fee in ETH to `feeWallet` before executing swap
    uint swapAmount = _collectFee(recipient, amount);

    // Wrap ETH to WETH and approve xfer
    IWETH WETH = IWETH(_zimaRouter.WETH());
    WETH.deposit{value: swapAmount}();    
    WETH.approve(address(_router), swapAmount);

    // Deserialize the pool address to retrieve fee
    address poolAddr = abi.decode(data, (address));
    uint24 fee = IUniswapV3Pool(poolAddr).fee();
    
    // Build the params
    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
      tokenIn: address(WETH),
      tokenOut: tokenTo,
      fee: fee,
      recipient: recipient,
      deadline: deadline,
      amountIn: swapAmount,
      amountOutMinimum: amountOutMin,
      sqrtPriceLimitX96: 0
      });

    // Execute the swap
    _router.exactInputSingle(params);
  }
  
  
  /** INTERNAL FUNCTIONS **/

  function _getMostLiquidFeeTier(address token0, address token1) internal view returns(uint24) {
    uint24[] memory feeTiers = new uint24[](3);
    feeTiers[0] = 500;   // 0.05%
    feeTiers[1] = 3000;  // 0.3%
    feeTiers[2] = 10000; // 1%
    uint24 targetFeeTier = 0;
    uint128 highestLiq = 0;

    for (uint i = 0; i < feeTiers.length; i++) {
      address poolAddr = _factory.getPool(token0, token1, feeTiers[i]);
      if (poolAddr != address(0)) {
        IUniswapV3Pool pool = IUniswapV3Pool(poolAddr);
        uint128 liq = pool.liquidity();
        if (liq > highestLiq) {
          highestLiq = liq;
          targetFeeTier = feeTiers[i];
        }
      }
    }

    return targetFeeTier;
  }
  
  function _collectFee(address recipient, uint ethAmount) internal returns(uint) {
    uint feeBps = _zimaRouter.feeBps(recipient);
    uint fee = ethAmount * feeBps / 10000;
    address payable feeWallet = _zimaRouter.feeWallet();
    (bool sent,) = feeWallet.call{value: fee}("");
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
