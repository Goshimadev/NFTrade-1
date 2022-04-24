// SPDX-License-Identifier: Unlicensed
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721{
    constructor(address account1, address account2) ERC721("MockNFT", "MNFT") {
        _mint(account1, 1);
        _mint(account2, 2);
    }
}