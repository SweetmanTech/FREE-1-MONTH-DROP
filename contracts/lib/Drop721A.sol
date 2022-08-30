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
    /// @notice Wrong price for purchase
    error Purchase_WrongPrice(uint256 correctPrice);

    constructor(string memory _name, string memory _symbol)
        ERC721A(_name, _symbol)
    {
        uint64 ONE_DAY = 60 * 60 * 24;
        uint64 ONE_MONTH = ONE_DAY * 31;
        publicSaleStart = block.timestamp;
        publicSaleEnd = block.timestamp + ONE_MONTH;
    }

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice This allows the user to purchase a edition edition
    /// at the given price in the contract.
    function _purchase(uint256 quantity) internal returns (uint256) {
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

    /// @notice Sale details
    /// @return IERC721Drop.SaleDetails sale information details
    function saleDetails() external view returns (SaleDetails memory) {
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
                maxSupply: 1000000,
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
}
