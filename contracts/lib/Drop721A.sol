// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "erc721a/contracts/ERC721A.sol";
import "../interfaces/IDrop721A.sol";

contract Drop721A is ERC721A, IDrop721A {
    /// @notice music metadata
    string internal musicMetadata;
    /// @notice contract metadata
    string internal contractMetadata;
    /// @notice Public Sale Start Time
    uint256 public publicSaleStart;
    /// @notice Public Sale End Time
    uint256 public publicSaleEnd;

    /// @notice Sale is inactive
    error Sale_Inactive();
    /// @notice Too many purchase for address
    error Purchase_TooManyForAddress();
    /// @notice NFT sold out
    error Mint_SoldOut();

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _publicSaleStart
    ) ERC721A(_name, _symbol) {
        uint64 ONE_DAY = 60 * 60 * 24;
        uint64 ONE_MONTH = ONE_DAY * 31;
        publicSaleStart = _publicSaleStart;
        publicSaleEnd = _publicSaleStart + ONE_MONTH;
    }

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice Allows user to mint tokens at a quantity
    modifier canMintTokens(uint256 quantity) {
        SaleDetails memory config = saleDetails();
        if (quantity + _totalMinted() > config.maxSupply) {
            revert Mint_SoldOut();
        }

        _;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function _purchase(uint256 quantity) internal returns (uint256) {
        _lessThanMaxSalePurchasePerAddress(quantity);
        uint256 start = _nextTokenId();
        _mint(msg.sender, quantity);

        emit Sale({
            to: msg.sender,
            quantity: quantity,
            pricePerToken: 0,
            firstPurchasedTokenId: start
        });
        return start;
    }

    /// @notice Public sale active
    function _publicSaleActive() internal view returns (bool) {
        return
            publicSaleStart <= block.timestamp &&
            publicSaleEnd > block.timestamp;
    }

    /// @notice Public sale active
    function _lessThanMaxSalePurchasePerAddress(uint256 _quantity)
        internal
        view
    {
        SaleDetails memory config = saleDetails();
        if (
            config.maxSalePurchasePerAddress != 0 &&
            _numberMinted(msg.sender) + _quantity >
            config.maxSalePurchasePerAddress
        ) {
            revert Purchase_TooManyForAddress();
        }
    }

    /// @notice Sale details
    /// @return IERC721Drop.SaleDetails sale information details
    function saleDetails() public view returns (SaleDetails memory) {
        return
            SaleDetails({
                publicSaleActive: _publicSaleActive(),
                presaleActive: false,
                publicSalePrice: 0,
                publicSaleStart: publicSaleStart,
                publicSaleEnd: publicSaleEnd,
                presaleStart: 0,
                presaleEnd: 0,
                presaleMerkleRoot: 0x0000000000000000000000000000000000000000000000000000000000000000,
                totalMinted: _totalMinted(),
                maxSupply: 100,
                maxSalePurchasePerAddress: 1
            });
    }

    /// @notice Returns the starting token ID.
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /// @notice Returns song metadata.
    function songURI() public view returns (string memory) {
        return musicMetadata;
    }

    /// @notice Returns the contract metadata.
    function contractURI() public view returns (string memory) {
        return musicMetadata;
    }
}
