// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Fortune is ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply {
    string public name="Fortune";
      
    uint256[] supplies = [250, 250, 250];
    uint256[] minted = [0, 0, 0];
    // uint256[] rates = [0 ether, 0 ether, 0 ether];
    uint256[] WhitelistCount=[0, 0, 0];

    mapping(uint => string) public tokenURI;
    mapping (address => uint) public whitelist;
    
    event Log(string msg, address _id, uint count, uint addressvalue);

    constructor() ERC1155("") {
        name=name;        
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

    function mintBatch(address[] memory _to, uint _id) 
    external 
    onlyOwner
    whenNotPaused
    validTokenId(_id)
    {
        for (uint i=0; i<_to.length; i++) {
            mint(_to[i], _id); 
        }        
    }   
    
    function mint(address _to, uint _id) 
        internal 
        onlyWhitelistAddress (_id)        
    {
        require(_id <= supplies.length && _id >0, "Token doesn't exist");    
        uint256 index=_id-1;

        require(minted[index] + 1 <= supplies[index], "Not enough supply");        
        _mint(_to, _id, 1, "");
        minted[index]+=1;
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
    function WhitelistAddresses(address[] memory _addresses, uint256 _id) public 
        onlyOwner
        validTokenId (_id)       
    {
        uint256 count=0;
        for (uint i=0; i<_addresses.length; i++) {
            emit Log("in for loop", _addresses[i], count, whitelist[_addresses[i]]);            
            if (whitelist[_addresses[i]] == 0) {                
                whitelist[_addresses[i]]=_id;                         
                count +=1;
            }   
            else     {
                emit Log("address is already whitelisted", _addresses[i], WhitelistCount[_id-1], whitelist[_addresses[i]]);                
            }               
        }
        require(WhitelistCount[_id-1]+count<=supplies[_id-1], "Exceed maxSupply");
        WhitelistCount[_id-1] += count;
    }        

    function RemoveWhitelist(address[] memory _addresses, uint256 _id) public 
        onlyOwner
        validTokenId (_id) 
    {
        uint256 count=0;
        for (uint i=0; i<_addresses.length; i++) {
            
            if (whitelist[_addresses[i]] !=0) {                
                whitelist[_addresses[i]]=0;
                count +=1;
            }
            else     {
                emit Log("Adress is not already whitelisted", _addresses[i], WhitelistCount[_id-1], whitelist[_addresses[i]]);                                
            }  
                       
        }        
        WhitelistCount[_id-1] -= count; 
        
    }
    function IsWhitelisted(address _address) public view returns (uint) {                
        return whitelist[_address];        
    }
    
    function getWhitelistCount(uint _id) public view returns (uint) {                
        return WhitelistCount[_id-1];        
    }
    modifier onlyWhitelistAddress(uint _id) {
        emit Log("Modifer onlyWhitelistAddress", msg.sender, 0, whitelist[msg.sender]);
        require(whitelist[msg.sender] == _id, "Address not whitelisted. Cant mint.");
        _;
    }
    modifier validTokenId(uint256 _id) {
        emit Log("Modifer validTokenId", msg.sender, 0, whitelist[msg.sender]);
        require(_id <= supplies.length && _id >0, "Token doesn't exist");    
        _;
    }

}
