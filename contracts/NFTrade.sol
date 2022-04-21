// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract NFTrade {
  address[][] public participants; // participants[tradeId] == array of each owner participating in a trade
  address[][] public tokenContracts; // tokenContracts[tradeId] == array of each NFT involved in a trade
  uint[][] public tokenIds; // tokenContracts[tradeId] == array of token IDs involved in a trade

  constructor() {
    
  }
}
