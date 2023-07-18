// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "./Register.sol";

///////////////////////////////////////////////////////////////////////////////////////////////
//  _______  _______ _________ _______         _______ _________ _______  _______  _______   //
// (       )(  ____ \\__   __/(  ___  )       (  ____ \\__   __/(  ___  )(  ____ \(  ____ \  //
// | () () || (    \/   ) (   | (   ) |       | (    \/   ) (   | (   ) || (    \/| (    \/  //
// | || || || (__       | |   | (___) | _____ | (_____    | |   | (___) || |      | (__      //
// | |(_)| ||  __)      | |   |  ___  |(_____)(_____  )   | |   |  ___  || | ____ |  __)     //
// | |   | || (         | |   | (   ) |             ) |   | |   | (   ) || | \_  )| (        //
// | )   ( || (____/\   | |   | )   ( |       /\____) |   | |   | )   ( || (___) || (____/\  //
// |/     \|(_______/   )_(   |/     \|       \_______)   )_(   |/     \|(_______)(_______/  //
//                                                                                           //
///////////////////////////////////////////////////////////////////////////////////////////////

contract MetaStage is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, ERC721Burnable, Register {
    uint256 public MAX_SUPPLY = 50;               // Maximum token supply is 30
    uint256 public MINT_PRICE = 1000000000000000; // Minting price is 0.001 Eth

    uint256 public tokenIndex = 0;
    bool private isLocked;

    string private ticketUri = "https://bafkreifkucivi2xkfnt7wf5x2goypmzgp4xvkbdyqcoduotageb5zvqh4q.ipfs.nftstorage.link/";
    string private photoCardBaseUri = "https://bafybeigg2fsdhcipownntnoliefda273xmnyoh2tby5rtubjfba4hvcvfi.ipfs.nftstorage.link/";
    string private photoCardUri;

    mapping(address => bool) private _hasMinted;

    event unLock(uint256 indexed tokenIndex);

    constructor() ERC721("MetaStage", "MTS") {
        isLocked = true;
    }

    function MintTicket() public payable {
        require(!_hasMinted[msg.sender], "Already bought ticket");
        require(msg.value >= MINT_PRICE, "Insufficient funds to mint");
        require(MAX_SUPPLY > tokenIndex, "30 Tickets are already minted");

        uint256 tokenId = tokenIndex;

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, ticketUri);
        _hasMinted[msg.sender] = true;

        tokenIndex++;
    }

    function register(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Caller is not token owner");
        _register(tokenId);
    }

    function unregister(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Caller is not token owner");
        _unregister(tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override(ERC721, IERC721) {
        require(!isLocked, "Ticket is locked");
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        require(!isLocked, "Ticket is locked");
        super.safeTransferFrom(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override(ERC721, IERC721) {
        require(!isLocked, "Ticket is locked");
        super.transferFrom(from, to, tokenId);
    }

    function approve(address approved, uint256 tokenId) public override(ERC721, IERC721) {
        require(!isLocked, "Ticket is locked");
        super.approve(approved, tokenId);
    }
    
    function transformToPhoto() external {
    require(msg.sender == owner(), "Permission denied");
    for (uint i = 0; i < tokenIndex; i++) {
        photoCardUri = string(abi.encodePacked(photoCardBaseUri, uint256ToString(i+1), ".json"));
        _setTokenURI(i, photoCardUri);
    }
    isLocked = false;
    emit unLock(tokenIndex);
}

function uint256ToString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
        return "0";
    }
    
    uint256 temp = value;
    uint256 digits;
    
    while (temp != 0) {
        digits++;
        temp /= 10;
    }
    
    bytes memory buffer = new bytes(digits);
    
    while (value != 0) {
        digits--;
        buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
        value /= 10;
    }
    
    return string(buffer);
}


    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 barchSize
    ) internal override {
        if (registrations[firstTokenId]){
            _unregister(firstTokenId);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
