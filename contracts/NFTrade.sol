// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract NFTrade {
  address[][] public participants; // participants[tradeId] == array of each owner participating in a trade
  address[][] public tokenContracts; // tokenContracts[tradeId] == array of each NFT involved in a trade
  uint[][] public tokenIds; // tokenContracts[tradeId] == array of token IDs involved in a trade

  /** @dev Emitted when a swap is created.
   *  @param _id ID of swap.
   *  @param _creator Creator of swap.
   *  @param _recipient Recipient of swap. 
   */
  event SwapCreated(uint _id, address indexed _creator, address indexed _recipient);

  /** @dev Creates a swap for a recipient to approve.
   *  @param _recipient Recipient of the swap.
   *  @param _recipientIndex The index in the _tokenContracts and _tokenIds arrays
   *    at which the creator's tokens for trade are separated 
   *    by the recipient's tokens for trade.
   *  @param _tokenContracts The contracts for the tokens that will be swapped.
   *    The array begins with the contracts of the creator's tokens for trade
   *    and ends with the contracts of the recipient's tokens for trade, 
   *    with _recipientIndex indicating where they are separated.
   *  @param _tokenIds The IDs for the tokens that will be swapped.
   *    The array begins with the IDs of the creator's tokens for trade
   *    and ends with the IDs of the recipient's tokens for trade, 
   *    with _recipientIndex indicating where they are separated.
   */
  function createSwap(
    address _recipient,
    uint _recipientIndex,
    address[] memory _tokenContracts, 
    uint[] memory _tokenIds
  ) public {
    uint id = participants.length;
    require(
      _tokenContracts.length == _tokenIds.length,
      "Input array lengths do not match."
    );
    require(_tokenContracts.length >= 2, "Arrays not long enough.");
    require(_recipient != address(0), "Swap recipient cannot be 0x0.");
    require(
      _recipientIndex > 0 && _recipientIndex < _tokenContracts.length,
      "Invalid recipient index."
    );
    address[] memory _participants = new address[](_tokenContracts.length);
    for(uint i = 0; i < _tokenContracts.length; i++) {
      for (uint j = 0; j < i; j++) {
        if (_tokenContracts[i] == _tokenContracts[j] && _tokenIds[i] == _tokenIds[j])
          revert("Duplicate tokens.");
      }
      _participants[i] = (i < _recipientIndex) ? msg.sender : _recipient;
    }
    participants.push(_participants);
    tokenContracts.push(_tokenContracts);
    tokenIds.push(_tokenIds);
    emit SwapCreated(id, msg.sender, _recipient);
  }
}
