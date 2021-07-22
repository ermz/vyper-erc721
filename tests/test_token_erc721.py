import pytest
from brownie import Wei, ZERO_ADDRESS, accounts, token_erc721

@pytest.fixture
def _token_erc721():
    _token_erc721 = token_erc721.deploy({'from': accounts[0]})
    return _token_erc721

def test_token_mint(_token_erc721):
    initial_token_count = _token_erc721.viewOwnerCount({"from": accounts[1]})
    _token_erc721.mint(accounts[1], 619, {'from': accounts[0]})
    assert initial_token_count + 1 == _token_erc721.viewOwnerCount({'from': accounts[1]})

def test_token_transfer(_token_erc721):
    _token_erc721.mint(accounts[1], 407, {'from': accounts[0]})
    # No need to specify the 'from' since it's a view only function
    original_owner = _token_erc721.viewTokenOwner(407)
    assert original_owner == accounts[1]
    _token_erc721.transfer(accounts[2], 407, {'from': accounts[1]})
    assert _token_erc721.viewTokenOwner(407) == accounts[2]

def test_token_approve(_token_erc721):
    _token_erc721.mint(accounts[1], 123, {'from': accounts[0]})
    pre_approval = _token_erc721.viewIdApprovals(123, {'from': accounts[2]})
    assert pre_approval == False
    _token_erc721.approve(accounts[2], 123, {'from': accounts[1]})
    assert _token_erc721.viewIdApprovals(123, {'from': accounts[2]}) == True
    _token_erc721.revokePermission(accounts[2], 123, {'from': accounts[1]})
    assert _token_erc721.viewIdApprovals(123, {'from': accounts[2]}) == False

def test_approved_transfer(_token_erc721):
    _token_erc721.mint(accounts[1], 700, {'from': accounts[0]})
    _token_erc721.approve(accounts[2], 700, {'from': accounts[1]})
    original_token_owner = _token_erc721.viewOwnerCount({'from': accounts[1]})
    assert original_token_owner == 1
    assert _token_erc721.viewTokenOwner(700) == accounts[1]
    _token_erc721.transferFromApproved(accounts[3], 700, {'from': accounts[2]})
    assert _token_erc721.viewOwnerCount({'from': accounts[1]}) + 1 == original_token_owner
    assert _token_erc721.viewTokenOwner(700) == accounts[3]

def test_token_burn(_token_erc721):
    _token_erc721.mint(accounts[1], 888, {'from': accounts[0]})
    assert _token_erc721.viewTokenOwner(888) == accounts[1]
    assert _token_erc721.viewOwnerCount({'from': accounts[1]}) == 1
    _token_erc721.burn(888, {'from': accounts[1]})
    assert _token_erc721.viewTokenOwner(888) == ZERO_ADDRESS
    assert _token_erc721.viewOwnerCount({'from': accounts[1]}) == 0