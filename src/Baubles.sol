// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20, ERC20Permit } from "openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

import { MustBeMagistrate, MustBeNewTerm } from "./Errors.sol";


interface IKetherSortition {
  function getMagistrate() external view returns (address);
  function termNumber() external view returns (uint256);
}


/**
 * @title Baubles
 * @notice Once during each sortition term cycle, a jubilee can occur which
 * mints 1,621 baubles by the current magistrate.
 */
contract Baubles is ERC20Permit {
    /// :confetti:
    event Jubilee(uint256 termNumber, address magistrate, address to);

    IKetherSortition public immutable sortition;

    /// One bauble per KetherHomepage slot.
    uint256 public constant JUBILEE_AMOUNT = 1621;

    uint256 public lastMintedTerm = 0;

    constructor(IKetherSortition _sortition) ERC20("Baubles", "BAUB") ERC20Permit("Baubles") {
        sortition = _sortition;
    }

    /// @notice Baubles are non-divisible. 🙃
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    /// @notice Once per term, magistrate can call mint to create 1,621 baubles.
    /// @param to The address to mint the baubles to.
    function mint(address to) external {
        address magistrate = sortition.getMagistrate();
        if (_msgSender() != magistrate) {
            revert MustBeMagistrate();
        }

        uint256 termNumber = sortition.termNumber();
        if (termNumber <= lastMintedTerm) {
            revert MustBeNewTerm();
        }

        lastMintedTerm = termNumber;
        _mint(to, JUBILEE_AMOUNT);

        emit Jubilee(termNumber, magistrate, to);
    }
}
