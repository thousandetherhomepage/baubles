// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import { IKetherSortition, Baubles } from "../src/Baubles.sol";
import { MustBeMagistrate, MustBeNewTerm, NotStarted } from "../src/Errors.sol";

// MockSortition where anyone can change the magistrate and term, for testing.
contract MockSortition is IKetherSortition {
  address public _magistrate;

  uint256 public termNumber = 0;

  function setMagistrate(address m, uint256 term) external {
    _magistrate = m;
    termNumber = term;
  }

  function getMagistrate() external view returns (address) {
    return _magistrate;
  }
}

contract BaublesTest is Test {
    Baubles public baubles;
    MockSortition public sortition;

    function setUp() public {
        sortition = new MockSortition();
        baubles = new Baubles(IKetherSortition(sortition));

        vm.warp(baubles.AGE_OF_JUBILEE() + 1);
    }

    function test_MintSimple() public {
        address to = msg.sender;
        sortition.setMagistrate(to, 1);
        vm.prank(to);
        baubles.mint(to);
    }

    function test_MintTerms() public {
        uint256 amount = baubles.JUBILEE_AMOUNT();

        {
            address to = address(msg.sender);
            assertEq(baubles.balanceOf(to), 0);
            sortition.setMagistrate(to, 1);
            vm.prank(to);
            baubles.mint(to);
            assertEq(baubles.balanceOf(to), amount);
        }

        // New term, mint to self again
        {
            address to = address(msg.sender);
            sortition.setMagistrate(to, 2);
            vm.prank(to);
            baubles.mint(to);
            assertEq(baubles.balanceOf(to), 2 * amount);
        }

        // New term, mint to other
        {
            address to = address(msg.sender);
            address other = address(0x1234);
            sortition.setMagistrate(to, 3);
            vm.prank(to);
            baubles.mint(other);
            assertEq(baubles.balanceOf(to), 2 * amount);
            assertEq(baubles.balanceOf(other), amount);
        }

        // New term, other mints to self
        {
            address other = address(0x1234);
            sortition.setMagistrate(other, 4);
            vm.prank(other);
            baubles.mint(other);
            assertEq(baubles.balanceOf(other), 2 * amount);
        }
    }

    function test_Transfer() public {
        address to = address(0xabcd);
        address other = address(0x1234);
        sortition.setMagistrate(to, 1);
        vm.prank(to);
        baubles.mint(to);

        vm.prank(to);
        baubles.transfer(other, 42);

        assertEq(baubles.balanceOf(other), 42);
    }

    function test_RevertIf_NotStarted() public {
        vm.warp(baubles.AGE_OF_JUBILEE() - 42);

        address to = msg.sender;
        sortition.setMagistrate(to, 1);
        vm.expectRevert(NotStarted.selector);
        vm.prank(to);
        baubles.mint(to);
    }

    function test_RevertIf_MintAnon() public {
        sortition.setMagistrate(address(0x0), 1);

        address to = address(0xabcd);
        vm.expectRevert(MustBeMagistrate.selector);
        vm.prank(to);
        baubles.mint(to);
    }

    function test_RevertIf_MintTwice() public {
        sortition.setMagistrate(address(msg.sender), 1);

        address to = address(0xabcd);
        vm.expectRevert(MustBeMagistrate.selector);
        vm.prank(to);
        baubles.mint(to);
    }
}
