pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../contracts/interfaces/IZimaRouter.sol";
import "../contracts/UniswapV2Adapter.sol";
import "../contracts/UniswapV3Adapter.sol";
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

  address public _uniswapV2RouterAddr;
  address public _uniswapV3FactoryAddr;
  address public _uniswapV3RouterAddr;
  
  ZimaRouter public _zimaRouter;
  UniswapV2Adapter public _uniswapV2Adapter;
  UniswapV3Adapter public _uniswapV3Adapter;
  
  uint _ADAPTER_ID_UNISWAP_V2 = 2;
  uint _ADAPTER_ID_UNISWAP_V3 = 3;
  
  constructor() {
    _admin = msg.sender;    
    if(block.chainid == 1){
      _USDC = IERC20(0x7EA2be2df7BA6E54B1A9C70676f668455E329d29);
      _USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
      _uniswapV2RouterAddr = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
      _uniswapV3FactoryAddr = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
      _uniswapV3RouterAddr = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
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

  function getUniswapV3Adapter() public returns(IAdapter) {
    return _getUniswapV3Adapter();
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
      _uniswapV2Adapter = new UniswapV2Adapter(address(_zimaRouter), _uniswapV2RouterAddr);
      vm.startPrank(_admin);
      _zimaRouter.__addAdapter(_ADAPTER_ID_UNISWAP_V2, address(_uniswapV2Adapter));
      vm.stopPrank();
    }
    return _uniswapV2Adapter;
  }

  function _getUniswapV3Adapter() internal returns(IAdapter) {
    if(address(_uniswapV3Adapter) == address(0)) {
      getZimaRouter();
      _uniswapV3Adapter = new UniswapV3Adapter(
                                               address(_zimaRouter),
                                               _uniswapV3FactoryAddr,
                                               _uniswapV3RouterAddr
                                               );
      vm.startPrank(_admin);
      _zimaRouter.__addAdapter(_ADAPTER_ID_UNISWAP_V3, address(_uniswapV3Adapter));
      vm.stopPrank();
    }
    return _uniswapV3Adapter;
  }

}
