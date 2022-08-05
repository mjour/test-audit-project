// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge
* Aavegotchi Staking Diamond
* 
* Uses the diamond-2, version 1.3.4, diamond implementation:
* https://github.com/mudgen/diamond-2
/******************************************************************************/

import "./libraries/LibDiamond.sol";
import "./interfaces/IDiamondLoupe.sol";
import "./interfaces/IDiamondCut.sol";
import "./interfaces/IERC173.sol";
import "./interfaces/IERC165.sol";
import "./libraries/AppStorage.sol";
import "./interfaces/IERC1155Metadata_URI.sol";

contract StakingDiamond {
    AppStorage s;
    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event PoolTokensRate(uint256 _newRate);

    struct ConstructorArgs {
        address owner;        
    }

    constructor(IDiamondCut.FacetCut[] memory _diamondCut, ConstructorArgs memory _args) {
        require(_args.owner != address(0), "StakingDiamond: owner can't be address(0)");        
        LibDiamond.diamondCut(_diamondCut, address(0), new bytes(0));
        LibDiamond.setContractOwner(_args.owner);

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        s.ticketsBaseUri = "https://mywebsite.com/metadata/";

        s.poolTokensRate = 14;
        emit PoolTokensRate(14);

        // adding ERC165 data
        ds.supportedInterfaces[type(IERC165).interfaceId] = true;        
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        // ERC1155
        // ERC165 identifier for the main token standard.
        ds.supportedInterfaces[0xd9b67a26] = true;

        // ERC1155
        // ERC1155Metadata_URI
        ds.supportedInterfaces[IERC1155Metadata_URI.uri.selector] = true;

        // create wearable tickets:
        emit TransferSingle(tx.origin, address(0), address(0), 0, 0);
        emit TransferSingle(tx.origin, address(0), address(0), 1, 0);
        emit TransferSingle(tx.origin, address(0), address(0), 2, 0);
        emit TransferSingle(tx.origin, address(0), address(0), 3, 0);
        emit TransferSingle(tx.origin, address(0), address(0), 4, 0);
        emit TransferSingle(tx.origin, address(0), address(0), 5, 0);
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), "StakingDiamond: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {
        revert("StakingDiamond: Does not accept ether");
    }
}
