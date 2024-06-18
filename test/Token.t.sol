// SPDX-License-Identifier: NONE
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Token.sol";

contract TokenTest is Test {

  Token private _token;

  function setUp() public {
    _token = new Token("MyToken", "TOKEN", 18);
  }

  /// @notice Unit test for checking token decimal places
  function testDecimals() public {
    console.log(_token.decimals());
    assertEq(_token.decimals(), 18);
  }

  /// @notice Fuzz test for checking mint property
  function testMint(address recipient, uint amount) public {
    vm.assume(recipient != address(0));
    _token.mint(recipient, amount);
    console.log(_token.balanceOf(recipient));
    assertEq(_token.balanceOf(recipient), amount);
  }

  function testFork() public view {
    console.log(block.number);
    console.log(block.timestamp);
  }
  
}
