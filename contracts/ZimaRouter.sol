// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IWETH/IWeth.sol";
import "./interfaces/IAdapter.sol";
import "./interfaces/IZimaRouter.sol";

contract ZimaRouter is AccessControlEnumerable, IZimaRouter{

  using SafeERC20 for IERC20;
  
  /// @notice Identifier of the admin role
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
  
  /// @notice Address of wrapped native token
  IWETH _WETH;
  
  /// @notice Address of wallet that will accrue all fees (in ETH only)
  address payable _feeWallet;
  
  /// @notice Default fee to charge, in basis points
  uint _defaultFeeBps;

  /// @notice Map of all supported `Adapters`
  mapping(uint => IAdapter) _adapters;
  
  constructor(address admin) {

    // Initialize access control
    _setupRole(ADMIN_ROLE, admin);
    _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);

    // Set initial parameters
    _defaultFeeBps = 50;

    if(block.chainid == 1) {
      _WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    } else if(block.chainid == 5) {
      _WETH = IWETH(0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6);
    } else {
      revert("unsupported chain");
    }
  }

  receive() external payable{}
  
  modifier onlyAdmin() {
    require(hasRole(ADMIN_ROLE, msg.sender), "only admin");
    _;
  }

  /** ACCESS CONTROLLED FUNCTIONS **/

  
  function __setFeeWallet(address payable feeWallet_) external onlyAdmin {
    _feeWallet = feeWallet_;
    emit SetFeeWallet(_feeWallet);
  }

  function __addAdapter(uint adapterId, address adapterAddr) external onlyAdmin {
    require(address(_adapters[adapterId]) == address(0), "adapter already exists");
    _adapters[adapterId] = IAdapter(adapterAddr);
    emit AddAdapter(adapterId, adapterAddr);
  }
  

  /** USER INTERFACE **/

  function swapExactTokensForETH(
                                 uint adapterId,
                                 address payable recipient,
                                 address tokenFrom,
                                 uint amountIn,
                                 uint amountOutMin,
                                 uint deadline
                                 ) external {

    // Find the correct `Adapter` to user
    IAdapter adapter = _adapters[adapterId];

    // Make sure the `Adapter` exists
    require(address(adapter) != address(0), "adapter not found");

    // Transfer funds from user to `Adapter`
    IERC20(tokenFrom).safeTransferFrom(recipient, address(adapter), amountIn);

    // Execute the swap
    adapter.swapExactTokensForETH(recipient, tokenFrom, amountIn, amountOutMin, deadline);
  }
  
  function swapExactETHForTokens(
                                 uint adapterId,
                                 address recipient,
                                 address tokenTo,
                                 uint amountOutMin,
                                 uint deadline
                                 ) external payable {

    // Find the correct `Adapter` to user
    IAdapter adapter = _adapters[adapterId];

    // Make sure the `Adapter` exists
    require(address(adapter) != address(0), "adapter not found");

    // Execute the swap
    adapter.swapExactETHForTokens{value: msg.value}(recipient, tokenTo, amountOutMin, deadline);
  }

  
  
  /** VIEW FUNCTIONS **/

  function WETH() external view returns(address) {
    return address(_WETH);
  }
  
  function feeBps(address user) external view returns(uint) {
    return _defaultFeeBps;
  }

  function feeWallet() external view returns(address payable) {
    return _feeWallet;
  }
                          
}
