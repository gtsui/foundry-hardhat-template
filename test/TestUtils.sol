pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/interfaces/UniswapV2/IUniswapV2Router02.sol";
import "../contracts/interfaces/IZimaRouter.sol";
import "../contracts/UniswapV2Adapter.sol";
import "../contracts/ZimaRouter.sol";


contract TestUtils is Test {

  address public immutable _admin;
  address public immutable _user1 = 0x1111111111111111111111111111111111111111;
  address public immutable _user2 = 0x2222222222222222222222222222222222222222;
  address public immutable _user3 = 0x3333333333333333333333333333333333333333;
  address public immutable _user4 = 0x4444444444444444444444444444444444444444;
  address public immutable _user5 = 0x5555555555555555555555555555555555555555;
  address payable _feeWallet = payable(0x9999999999999999999999999999999999999999);

  IERC20 _USDC;
  IERC20 _USDT;

  IUniswapV2Router02 public _uniswapV2Router02;
  
  ZimaRouter public _zimaRouter;
  UniswapV2Adapter public _uniswapV2Adapter;
  
  constructor() {
    _admin = msg.sender;    
    if(block.chainid == 1){
      _USDC = IERC20(0x7EA2be2df7BA6E54B1A9C70676f668455E329d29);
      _USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
      _uniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
      deal(_admin, 10000e18);
      deal(_user1, 10000e18);
      deal(_user2, 10000e18);
      deal(_user3, 10000e18);
      deal(_user4, 10000e18);
      deal(_user5, 10000e18);
      deal(address(_USDT), _admin, 1000e6);
      deal(address(_USDT), _user1, 1000e6);
      deal(address(_USDT), _user2, 1000e6);
      deal(address(_USDT), _user3, 1000e6);
      deal(address(_USDT), _user4, 1000e6);
      deal(address(_USDT), _user5, 1000e6);
    } else {
      revert("unsupported chain");
    }
  }

  function getZimaRouter() public returns(IZimaRouter) {
    return _getZimaRouter();
  }

  function getUniswapV2Adapter() public returns(IAdapter) {
    return _getUniswapV2Adapter();
  }
  
  /** INTERNAL FUNCTIONS **/

  function _getZimaRouter() internal returns(IZimaRouter) {
    if(address(_zimaRouter) == address(0)) {
      vm.startPrank(_admin);
      _zimaRouter = new ZimaRouter(_admin);
      _zimaRouter.__setFeeWallet(_feeWallet);
      vm.stopPrank();
    }    
    return _zimaRouter;
  }

  function _getUniswapV2Adapter() internal returns(IAdapter) {
    if(address(_uniswapV2Adapter) == address(0)) {
      getZimaRouter();
      _uniswapV2Adapter = new UniswapV2Adapter(address(_zimaRouter), address(_uniswapV2Router02));
      vm.startPrank(_admin);
      _zimaRouter.__addAdapter(1, address(_uniswapV2Adapter));
      vm.stopPrank();
    }
    return _uniswapV2Adapter;
  }
  
}
