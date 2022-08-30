// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./lib/Drop721A.sol";

contract Drop is Drop721A {
    constructor(
        string memory _contractName,
        string memory _contractSymbol,
        string memory _musicMetadata,
        string memory _contractMetadata,
        uint256 _publicSaleStart
    ) Drop721A(_contractName, _contractSymbol, _publicSaleStart) {
        musicMetadata = _musicMetadata;
        contractMetadata = _contractMetadata;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function purchase(uint256 _quantity)
        external
        onlyPublicSaleActive
        canMintTokens(_quantity)
        returns (uint256)
    {
        uint256 firstMintedTokenId = _purchase(_quantity);
        return firstMintedTokenId;
    }

    /// @notice Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
        return songURI();
    }
}
