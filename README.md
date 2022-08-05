# Audit Test Instructions

This test audit is done to see how well you know Solidity, how well you can research and learn, and how well you can find smart contract issues and communicate them clearly and recommend ways to fix or handle them.

*To pass this test you must find and report all the major bugs and security vulnerabilities. You must write clearly, with enough detail about what is wrong and possible solutions. Your custom ERC721 facet must work.*

Note that for this test you can use resources on the Internet for help.
Some resources: 
* https://eips.ethereum.org/EIPS/eip-2535
* https://eip2535diamonds.substack.com/
* https://dev.to/mudgen
* https://eip2535diamonds.substack.com/p/introduction-to-the-diamond-standard
* https://github.com/mudgen/awesome-diamonds
* https://google.com
* https://eips.ethereum.org/EIPS/eip-721
* https://eips.ethereum.org/EIPS/eip-1155
* Other resources you find

### Time Limit

There is no time limit on the test, but the sooner it is done the sooner it can be evaulated.

## Part 1
1. Fork this private repo. Add mudgen and nesbitta to your version of the private repo. Do all the activity/work in your private repo.
1. Go to Settings in your private repo and turn on Issues.
1. Create and use the following Issue labels:
    * High Risk (red)
    * Medium Risk (brown)
    * Low Risk (yellow)
    * Informational (blue)
    * Fixed (green)

1. Audit the following Solidity files:
    * [StakingFacet.sol](contracts/facets/StakingFacet.sol)
    * [TicketsFacet.sol](contracts/facets/TicketsFacet.sol)
    * [Airdop.sol](contracts/Airdop.sol)
    * [StakingDiamond.sol](contracts/StakingDiamond.sol)
    * [AppStorage.sol](contracts/libraries/AppStorage.sol)
    * [LibStrings.sol](contracts/libraries/LibStrings.sol)

    Ignore the rest of the Solidity files for this audit.    
    
    Find and report any/all bugs and security vulnerabilities. Find and report any code or gas deficiencies.
    
    For each issue found create a separate issue in your private repo. Give a clear description of what the concern/issue is and give a recommendation on how to fix it. Use the issue labels.
    
    ### To pass this test you must find and report all the major bugs and security vulnerabilities.
    
## Part 2

Create the file `ERC721Facet.sol` in the `facets` directory and implement ERC721. This should be your own implementation, do not copy someone elses. This facet should work correctly with the [StakingDiamond](contracts/StakingDiamond.sol). Add it to the [deploy.js](scripts/deploy.js) file so that it gets deployed as part of the StakingDiamond.

Add an external function to `ERC721Facet.sol` that enables someone to purchase ERC721 tokens with tickets that are implemented in `TicketsFacet.sol`.

Any new state variables that are added may not use AppStorage or be added to the existing AppStorage struct or a nested struct in AppStorage. There is no reason for this condition other than to test your ability to find a good solution that works.

`ERC721Facet.sol` should work and have no bugs or security vulnerabilities. 

## When Done

When done let Mark James know so that he can review your work. You can create an issue that mentions Markor send him a message on discord: markjames_1221#1546

 


# Project Info

These contracts use [EIP-2535 Diamond Standard](https://eips.ethereum.org/EIPS/eip-2535).

Uses the [diamond-2](https://github.com/mudgen/diamond-2) implementation of EIP-2535 Diamond Standard, but is updated to use Solidity 0.8.

### Overview

This repository implements `contracts/StakingDiamond.sol`. This is a diamond that utilizes the facets found in `contracts/facets/`.

`TicketsFacet.sol` implements simple ERC1155 token functionality. The ERC1155 tokens are called 'tickets'. There are six different kinds of 'tickets'.

 `StakingFacet.sol` implements functions that enable people to stake Uniswap pool tokens. Staking these earns people frens or frens points which are a non-transferable points system. The frens points are calculated with the `frens` function. The `claimTickets` function enables people to claim or mint up to six different kinds of tokens.  Each different ticket kind has a different frens price which is specified in the `ticketCost` function.
 
 Diamonds are used to organize smart contract functionality in a modular and flexible way, and they are used for upgradeable systems and they overcome the max-contract size limitation. 

`StakingDiamond` is deployed using the `scripts/deploy.js` script.



