// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/AppStorage.sol";
import "../libraries/LibDiamond.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IERC1155TokenReceiver.sol";


contract StakingFacet {
    AppStorage internal s;
    bytes4 internal constant ERC1155_BATCH_ACCEPTED = 0xbc197c81; // Return value from `onERC1155BatchReceived` call if a contract accepts receipt (i.e `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event PoolTokensRate(uint256 _newRate);

    function frens(address _account) public view returns (uint256 frens_) {
        Account storage account = s.accounts[_account];        
        uint256 timePeriod = block.timestamp - account.lastFrensUpdate;
        frens_ = account.frens;
        // 86400 the number of seconds in 1 day        
        frens_ += ((account.poolTokens * s.poolTokensRate) * timePeriod) / 24 hours;        
    }

    function bulkFrens(address[] calldata _accounts) external view returns (uint256[] memory frens_) {
        frens_ = new uint256[](_accounts.length);
        for (uint256 i; i < _accounts.length; i++) {
            frens_[i] = frens(_accounts[i]);
        }
    }

    function updateFrens() internal {        
        Account storage account = s.accounts[tx.origin];
        account.frens = frens(tx.origin);
        account.lastFrensUpdate = uint40(block.timestamp);
    }

    function updateAccounts(address[] calldata _accounts) external {
        LibDiamond.enforceIsContractOwner();
        for (uint256 i; i < _accounts.length; i++) {
            address accountAddress = _accounts[i];
            Account storage account = s.accounts[accountAddress];
            account.frens = frens(accountAddress);
            account.lastFrensUpdate = uint40(block.timestamp);
        }
    }

    function updatePoolTokensRate(uint256 _newRate) external {
        LibDiamond.enforceIsContractOwner();
        s.poolTokensRate = _newRate;
        emit PoolTokensRate(_newRate);
    }

    function poolTokensRate() external view returns (uint256) {
        return s.poolTokensRate;
    }
    
    function migrateFrens(address[] calldata _stakers, uint256[] calldata _frens) external {
        LibDiamond.enforceIsContractOwner();
        require(_stakers.length == _frens.length, "StakingFacet: stakers not same length as frens");
        for (uint256 i; i < _stakers.length; i++) {
            Account storage account = s.accounts[_stakers[i]];
            account.frens = uint104(_frens[i]);
            account.lastFrensUpdate = uint40(block.timestamp);
        }
    }

    function switchFrens(address _old, address _new) external {
        LibDiamond.enforceIsContractOwner();
        Account storage oldAccount = s.accounts[_old];
        Account storage newAccount = s.accounts[_new];
        (oldAccount.frens, newAccount.frens) = (newAccount.frens, oldAccount.frens);
        oldAccount.lastFrensUpdate = uint40(block.timestamp);
        newAccount.lastFrensUpdate = uint40(block.timestamp);
    }
    

    function stakePoolTokens(uint256 _poolTokens) external {
        updateFrens();        
        Account storage account = s.accounts[tx.origin];        
        account.poolTokens += _poolTokens;                
        IERC20(s.poolContract).transferFrom(tx.origin, address(this), _poolTokens);
    }



    function staked(address _account)
        external
        view
        returns (
            uint256 poolTokens_
        )
    {
        poolTokens_ = s.accounts[_account].poolTokens;
    }
    

    function withdrawPoolStake(uint256 _poolTokens) external {
        updateFrens();        
        uint256 accountPoolTokens = s.accounts[tx.origin].poolTokens;
        require(accountPoolTokens >= _poolTokens, "Can't withdraw more poolTokens than in account");
        s.accounts[tx.origin].poolTokens = accountPoolTokens - _poolTokens;
        IERC20(s.poolContract).transfer(tx.origin, _poolTokens);
    }
    
    function claimTickets(uint256[] calldata _ids, uint256[] calldata _values) external {
        require(_ids.length == _values.length, "Staking: _ids not the same length as _values");
        updateFrens();    
        uint256 frensBal = s.accounts[tx.origin].frens;
        // gas optimization
        unchecked {            
            for (uint256 i; i < _ids.length; i++) {
                uint256 id = _ids[i];
                uint256 value = _values[i];
                require(id < 6, "Staking: Ticket not found");
                uint256 l_ticketCost = ticketCost(id);
                uint256 cost = l_ticketCost * value;            
                require(frensBal >= cost, "Staking: Not enough frens points");
                frensBal -= cost;
                s.tickets[id].accountBalances[tx.origin] += value;
                s.tickets[id].totalSupply += uint96(value);
            }
        }
        s.accounts[tx.origin].frens = frensBal;
        emit TransferBatch(tx.origin, address(0), tx.origin, _ids, _values);
        uint256 size;
        address sender = tx.origin;
        assembly {
            size := extcodesize(sender)
        }
        if (size > 0) {
            require(
                ERC1155_BATCH_ACCEPTED == IERC1155TokenReceiver(tx.origin).onERC1155BatchReceived(tx.origin, address(0), _ids, _values, new bytes(0)),
                "Staking: Ticket transfer rejected/failed"
            );
        }
    }

    function ticketCost(uint256 _id) public pure returns (uint256 _frensCost) {
        if (_id == 0) {
            _frensCost = 50e18;
        } else if (_id == 1) {
            _frensCost = 250e18;
        } else if (_id == 2) {
            _frensCost = 500e18;
        } else if (_id == 3) {
            _frensCost = 2_500e18;
        } else if (_id == 4) {
            _frensCost = 10_000e18;
        } else if (_id == 5) {
            _frensCost = 50_000e18;
        } else {
            revert("Staking: _id does not exist");
        }
    }
}
