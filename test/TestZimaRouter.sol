pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./TestUtils.sol";
import "../contracts/ZimaRouter.sol";
import "../contracts/UniswapV2Adapter.sol";

contract TestZimaRouter is TestUtils {

  using SafeERC20 for IERC20;
  
  function setUp() public {
    getZimaRouter();
    getUniswapV2Adapter();
  }

  function testSwapExactTokensForETH() public {

    uint SWAP_AMOUNT = 200e6;
    
    uint userUsdtBefore = _USDT.balanceOf(_user1);
    uint userEthBefore = _user1.balance;
    uint feeWalletEthBefore = _feeWallet.balance;
    
    vm.startPrank(_user1);
    _USDT.safeApprove(address(_zimaRouter), SWAP_AMOUNT);
    _zimaRouter.swapExactTokensForETH(
                                      1,
                                      payable(_user1),
                                      address(_USDT),
                                      SWAP_AMOUNT,
                                      0,
                                      block.timestamp
                                      );
    vm.stopPrank();

    uint userUsdtAfter = _USDT.balanceOf(_user1);
    uint userEthAfter = _user1.balance;
    uint feeWalletEthAfter = _feeWallet.balance;
    uint routerUsdtBalance = _USDT.balanceOf(address(_zimaRouter));
    uint routerEthBalance = address(_zimaRouter).balance;
    uint adapterUsdtBalance = _USDT.balanceOf(address(_uniswapV2Adapter));
    uint adapterEthBalance = address(_uniswapV2Adapter).balance;
    
    assertEq(userUsdtBefore - userUsdtAfter, SWAP_AMOUNT);
    assertGt(userEthAfter - userEthBefore, 0);
    assertGt(feeWalletEthAfter - feeWalletEthBefore, 0);
    assertEq(routerUsdtBalance, 0);
    assertEq(routerEthBalance, 0);
    assertEq(adapterUsdtBalance, 0);
    assertEq(adapterEthBalance, 0);
    
  }

  function testSwapExactETHForTokens() public {

    uint SWAP_AMOUNT = 1e18;
    
    uint userEthBefore = _user1.balance;
    uint userUsdtBefore = _USDT.balanceOf(_user1);
    uint feeWalletEthBefore = _feeWallet.balance;
   
    vm.startPrank(_user1);
    _zimaRouter.swapExactETHForTokens{value: SWAP_AMOUNT}(
                                                          1,
                                                          _user1,
                                                          address(_USDT),
                                                          0,
                                                          block.timestamp
                                                          );
    vm.stopPrank();

    uint userEthAfter = _user1.balance;
    uint userUsdtAfter = _USDT.balanceOf(_user1);
    uint feeWalletEthAfter = _feeWallet.balance;
    uint routerUsdtBalance = _USDT.balanceOf(address(_zimaRouter));
    uint routerEthBalance = address(_zimaRouter).balance;
    uint adapterUsdtBalance = _USDT.balanceOf(address(_uniswapV2Adapter));
    uint adapterEthBalance = address(_uniswapV2Adapter).balance;
    
    assertEq(userEthBefore - userEthAfter, SWAP_AMOUNT);
    assertEq(feeWalletEthAfter - feeWalletEthBefore, SWAP_AMOUNT * 50 / 10000);
    assertGt(userUsdtAfter - userUsdtBefore, 0);
    assertEq(routerUsdtBalance, 0);
    assertEq(routerEthBalance, 0);
    assertEq(adapterUsdtBalance, 0);
    assertEq(adapterEthBalance, 0);
    
  }
  
  
}
