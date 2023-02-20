// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SoulBoundToken is ERC721, Ownable {
    mapping (address => bool) public owners;
    mapping (address => string) public image;
    mapping (address => bool) public requestStatus;
    mapping (address => bool) public openVerifications;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("SoulBoundToken", "SBT") {}

    function safeMint(address to, string memory _image) public onlyOwner {
        require(!owners[to], "Token is aleady owned");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        image[to] = _image;
        owners[to] = true;
    }

    function incomingVerification(address to, address from) public {
        require(owners[to], "Address doens't own an identity");
        require(!openVerifications[from], "There is already a pending request");
        openVerifications[from] = true;
    }

    function handleVerification(address from, bool _response) public returns(string memory){
        require(openVerifications[from], "No pending request from this user");
        requestStatus[from] = _response;
        openVerifications[from] = false;
        return(returnData(from, ""));
    }

    function returnData(address from, string memory _response) public view returns(string memory){
        if(requestStatus[from]){
            _response = "Valid identity";
        } else {
            _response = "Access denied";
        }
        return(_response);
    }

    function updateMetadata(uint256 tokenId, string memory _image) private {
        require(ownerOf(tokenId) == msg.sender, "Only the token owner can change metadata");
        image[msg.sender] = _image;
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Only the owner of the token can burn it.");
        _burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256) pure override internal {
        require(from == address(0) || to == address(0), "This a Soulbound token. It cannot be transferred. It can only be burned by the token owner.");
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
        owners[msg.sender] = false;
    }
}