// SPDX-License-Identifier
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

  /// @notice Number of decimal places
  uint8 private _decimals;
  
  constructor(
              string memory name_,
              string memory symbol_,
              uint8 decimals_
              ) ERC20(name_, symbol_) {
    _decimals = decimals_;
  }

  /// @notice Overrides the standard 18 decimal places of OZ ERC20 contract
  /// with user-set decimals from constructor
  /// @return uint8 Number of decimal places
  function decimals() public view override returns(uint8){
    return _decimals;
  }
  
  /// @notice Mints tokens to a recipient. This is an external function
  /// with no permissions so anyone can mint themselves infinite tokens.
  /// Use for testnet purposes only.
  /// @param recipient Account to mint tokens to
  /// @param amount Amount of tokens to mint
  function mint(address recipient, uint amount) external returns(bool){
    _mint(recipient, amount);
    return true;
  }
  
}
