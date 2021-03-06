// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/// @custom:security-contact shanto12@gmail.com
contract Fortune is ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply {
  string public name;
  string public symbol;

  uint256[] supplies = [4000, 250, 250, 250, 250];
  uint256[] minted = [0, 0, 0, 0, 0];
  uint256[] rates = [.0001 ether, 0 ether, 0 ether, 0 ether, 0 ether];
  // uint256[] supplies = [4000, 250, 250, 250, 250];


  mapping(uint => string) public tokenURI;

    constructor() ERC1155("") {
    name = "Fortune";
    symbol = "FORT";    
  }

    function setURI(uint _id, string memory _uri) external onlyOwner {
    tokenURI[_id] = _uri;
    emit URI(_uri, _id);
  }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

 function mint(address _to, uint _id, uint _amount) 
 external 
 onlyOwner
 payable
  {
    require(_id <= supplies.length, "Token doesn't exist");
    require(_id >0, "Token doesn't exist");
    uint256 index=_id-1;

    require(minted[index] + _amount <= supplies[index], "Not enough supply");
    require(msg.value >= _amount * rates[index], "Not enough ether sent");
    _mint(_to, _id, _amount, "");
    minted[index]+=_amount;
  }

    function mintBatch(address _to, uint[] memory _ids, uint[] memory _amounts) external onlyOwner {
    _mintBatch(_to, _ids, _amounts, "");
  }

  function burn(uint _id, uint _amount) external {
    _burn(msg.sender, _id, _amount);
  }

  function burnBatch(uint[] memory _ids, uint[] memory _amounts) external {
    _burnBatch(msg.sender, _ids, _amounts);
  }

  function burnForMint(address _from, uint[] memory _burnIds, uint[] memory _burnAmounts, uint[] memory _mintIds, uint[] memory _mintAmounts) external onlyOwner {
    _burnBatch(_from, _burnIds, _burnAmounts);
    _mintBatch(_from, _mintIds, _mintAmounts, "");
  }
  function uri(uint _id) public override view returns (string memory) {
    return tokenURI[_id];
  }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
