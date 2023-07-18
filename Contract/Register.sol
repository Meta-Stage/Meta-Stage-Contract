// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Register {

    mapping(uint256 => bool) public registrations;

    event RegisterNFT(address indexed from, uint256 indexed tokenId);
    event UnregisterNFT(uint indexed tokenId);

    function _register(uint256 tokenId) internal {
        require(!registrations[tokenId], "This token is already registered");
        
        registrations[tokenId] = true;

        emit RegisterNFT(msg.sender, tokenId);
    }

    function _unregister(uint256 tokenId) internal {
        require(registrations[tokenId], "This token is not registered");
        registrations[tokenId] = false;

        emit UnregisterNFT(tokenId);
    }
}