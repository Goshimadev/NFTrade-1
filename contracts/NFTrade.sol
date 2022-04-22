// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

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

  /** @dev Requires that caller is the recipient of a certain swap.
   *  @param _id ID of the swap.
   */
  modifier onlySwapRecipient(uint _id) {
    address[] memory arr = participants[_id];
    require(arr[arr.length - 1] == msg.sender, "Caller must be swap recipient.");
    _;
  }

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
    for (uint i = 0; i < _tokenContracts.length; i++) {
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

  /** @dev Executes a swap. Called by the recipient.
   *  @param _id ID of the swap.
   */
  function executeSwap(uint _id) onlySwapRecipient(_id) public {
    address[] memory swapParticipants = participants[_id];
    for (uint i = 0; i < participants[_id].length; i++) {
      IERC721 tokenContract = IERC721(tokenContracts[_id][i]);
      address to = swapParticipants[(swapParticipants[i] == msg.sender) ? 0 : swapParticipants.length - 1]; 
      tokenContract.safeTransferFrom(swapParticipants[i], to, tokenIds[_id][i]);
    }
  }
}

