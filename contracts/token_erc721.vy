# @version ^0.2.0

_minter: address

tokenIdToOwner: HashMap[uint256, address]

tokenIdtoApprovals: HashMap[uint256, HashMap[address, bool]]

tokenOwnerCount: HashMap[address, uint256]

# A HashMap for token library, that holds an address -> which leads to an array of every NFT they own
# This could be wrong, I think arrays in Vyper can't be dynamic

@external
def __init__():
    _minter = msg.sender

@external
def mint(_receiver: address, _tokenId: uint256) -> bool:
    assert msg.sender == minter, "Only the 'minter' can 'mint', hence why he's the 'minter'."
    assert _receiver != ZERO_ADDRESS
    assert tokenIdToOwner[_tokenId] == ZERO_ADDRESS, "This token ID already exists"

    self.tokenIdToOwner[_tokenId] = _receiver
    self.tokenOwnerCount[_receiver] += 1

    return True

@external
def transfer(_receiver: address, _tokenId: uint256) -> bool:
    assert msg.sender == self.tokenIdToOwner[_tokenId], "Must be the owner of token to transfer"
    assert _receiver != ZERO_ADDRESS

    self.tokenIdToOwner[_tokenId] = _receiver
    self.tokenOwnerCount[msg.sender] -= 1
    self.tokenOwnerCount[_receiver] += 1

    return True

@external
def approve(_receiver: address, _tokenId: uint256) -> bool:
    assert msg.sender == self.tokenIdToOwner[_tokenId], "Must be owner of token to give approval"
    assert _receiver != ZERO_ADDRESS

    self.tokenIdtoApprovals[_tokenId][_receiver] = True
    return True

@external
def revokePermission(_addr: address, _tokenId: uint256) -> bool:
    assert msg.sender == self.tokeIdTOOwner[_tokenId], "Must be the owner to revoke permission"
    
    self.tokenIdtoApprovals[_tokenId][_addr] = False
    return True

@external
def transferFromApproved(_receiver: address, _tokenId: uint256) -> bool:
    assert True == self.tokenIdtoApprovals[_tokenId][msg.sender], "You don't have approval"
    assert _receiver != ZERO_ADDRESS

    previousOwner = self.tokenIdToOwner[_tokenId]

    self.tokeIdToOwner[_tokenId] = _receiver
    self.tokenIdtoApprovals[_tokenId][msg.sender] = False
    self.tokenOwnerCount[previousOwner] -= 1
    self.tokenOwnerCount[_receiver] += 1
    return True

@external
def burn(_tokenId: uint256) -> bool:
    # This checks to see if you are the owner or you have permission
    # assert msg.sender == self.tokenIdToOwner[_tokenId] || True == self.tokenIdtoApprovals[_tokenId][msg.sender], "You must be owner or have permission"

    originalOwner = self.tokenIdToOwner[_tokenId]

    #Have to check if clear function works
    self.tokeIdToOwner[_tokenId].clear()
    self.tokenOwnerCount[originalOwner] -= 1
    self.tokenIdtoApprovals[_tokenId].clear()

    return True

