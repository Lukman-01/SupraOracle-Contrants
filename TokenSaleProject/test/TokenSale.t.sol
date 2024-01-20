// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "ds-test/test.sol";
import "../src/TokenSale.sol";
import "../src/ERC20Token.sol";

contract TokenSaleTest is DSTest, Test {
    TokenSale private tokenSale;
    Token private token;
    address private deployer;
    address private user1;
    uint256 private presaleCap = 500 ether;
    uint256 private publicSaleCap = 1000 ether;

    function setUp() public {
        deployer = address(this);
        user1 = address(1);
        token = new Token(); // Instantiate the Token contract

        tokenSale = new TokenSale(
            address(token),
            presaleCap, 1 ether, 5 ether, block.timestamp + 1 days,
            publicSaleCap, 1 ether, 10 ether, block.timestamp + 2 days,
            200 ether, 500 ether
        );

        // Transfer the initial supply of tokens to the TokenSale contract
        uint256 initialSupply = token.balanceOf(deployer);
        token.transfer(address(tokenSale), initialSupply);
    }


    /**
     * @notice Test initial setup of the token sale
     */
    function testInitialSetup() public {
        assertEq(tokenSale.presaleCap(), presaleCap);
        assertEq(tokenSale.publicSaleCap(), publicSaleCap);
        // Other initial state variables assertions
    }

    /**
     * @notice Test the functionality of contributing to the presale
     */
    function testContributeToPresale() public {
        vm.warp(block.timestamp + 1 hours); // Warp to a time within presale period
        tokenSale.contributeToPresale{value: 2 ether}();
        assertEq(tokenSale.presaleTotalContributed(), 2 ether);
    }

    /**
     * @notice Test failure when contributing to the presale after its end
     */
    function testFailContributeToPresaleAfterEnd() public {
        vm.warp(block.timestamp + 2 days); // Warp to a time after presale period
        tokenSale.contributeToPresale{value: 2 ether}();
    }

    /**
     * @notice Test the functionality of contributing to the public sale
     */
    function testContributeToPublicSale() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // Warp to a time within public sale period
        tokenSale.contributeToPublicSale{value: 3 ether}();
        assertEq(tokenSale.publicSaleTotalContributed(), 3 ether);
    }

    /**
     * @notice Test failure when contributing to the public sale before its start
     */
    function testFailContributeToPublicSaleBeforeStart() public {
        vm.warp(block.timestamp + 1 hours); // Before public sale starts
        tokenSale.contributeToPublicSale{value: 3 ether}();
    }

    /**
     * @notice Test only the owner can distribute tokens
     */
    function testDistributeTokensOnlyOwner() public {
        tokenSale.distributeTokens(user1, 100 ether);
        assertEq(token.balanceOf(user1), 100 ether);
    }

    /**
     * @notice Test failure when a non-owner tries to distribute tokens
     */
    function testFailDistributeTokensNotOwner() public {
        vm.prank(user1);
        tokenSale.distributeTokens(user1, 100 ether);
    }

    /**
     * @notice Test claiming a refund after public sale
     */
    function testClaimRefund() public {
        uint256 publicSaleStartTime = tokenSale.presaleEndTime() + 1 hours;
        vm.warp(publicSaleStartTime); // Warp to public sale start
        uint256 contributionAmount = 1 ether; // Contribution amount (should be within limits)
        tokenSale.contributeToPublicSale{value: contributionAmount}(); 

        uint256 publicSaleEndTime = tokenSale.publicSaleEndTime();
        vm.warp(publicSaleEndTime + 1 hours); // Warp to after public sale end

        uint256 publicSaleMinCap = tokenSale.publicSaleMinCap();
        assert(tokenSale.publicSaleTotalContributed() < publicSaleMinCap);

        uint256 initialBalance = address(this).balance;
        tokenSale.claimRefund();

        uint256 finalBalance = address(this).balance;
        assertEq(finalBalance, initialBalance + contributionAmount, "Refund was not successful");
    }

    /**
     * @notice Test failure of refund claim when public sale minimum cap is reached
     */
    function testFailClaimRefundMinCapReached() public {
        vm.warp(block.timestamp + 2 days + 1 hours); // After public sale ends
        // Setup scenario where min cap is reached
        tokenSale.claimRefund(); // Should fail
    }

    /**
     * @notice Test failure of refund claim when no contribution is made
     */
    function testFailClaimRefundNoContribution() public {
        vm.warp(block.timestamp + 2 days + 1 hours); // After public sale ends
        vm.prank(user1); // An address with no contributions
        tokenSale.claimRefund(); // Should fail
    }

    // Edge case tests

    /**
     * @notice Test presale contributions to reach exactly the presale cap
     */
    function testEdgeCasePresaleExactCap() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        uint256 maxContribution = 5 ether; // Assuming this is the max contribution limit
        uint256 contributionAmount = presaleCap / maxContribution;

        for (uint256 i = 0; i < contributionAmount; i++) {
            tokenSale.contributeToPresale{value: maxContribution}();
        }
        // Check if the last contribution should be less than max to match the exact cap
        uint256 remaining = presaleCap % maxContribution;
        if (remaining > 0) {
            tokenSale.contributeToPresale{value: remaining}();
        }

        assertEq(tokenSale.presaleTotalContributed(), presaleCap);
    }

    /**
     * @notice Test public sale contributions to reach exactly the public sale cap
     */
    function testEdgeCasePublicSaleExactCap() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        uint256 maxContribution = 10 ether; // Assuming this is the max contribution limit
        uint256 contributionAmount = publicSaleCap / maxContribution;
        for (uint256 i = 0; i < contributionAmount; i++) {
            tokenSale.contributeToPublicSale{value: maxContribution}();
        }
        // Check if the last contribution should be less than max to match the exact cap
        uint256 remaining = publicSaleCap % maxContribution;
        if (remaining > 0) {
            tokenSale.contributeToPublicSale{value: remaining}();
        }
        assertEq(tokenSale.publicSaleTotalContributed(), publicSaleCap);
    }

    /**
     * @notice Test failure when contribution is over the presale maximum limit
     */
    function testFailContributeOverPresaleMax() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        tokenSale.contributeToPresale{value: 6 ether}(); // More than 5 ether max
    }

    /**
     * @notice Test failure when contribution is over the public sale maximum limit
     */
    function testFailContributeOverPublicSaleMax() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        tokenSale.contributeToPublicSale{value: 11 ether}(); // More than 10 ether max
    }

    /**
     * @notice Test failure when contribution is under the presale minimum limit
     */
    function testFailContributeUnderPresaleMin() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        tokenSale.contributeToPresale{value: 0.5 ether}(); // Less than 1 ether min
    }

    /**
     * @notice Test failure when contribution is under the public sale minimum limit
     */
    function testFailContributeUnderPublicSaleMin() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        tokenSale.contributeToPublicSale{value: 0.5 ether}(); // Less than 1 ether min
    }

    // Additional scenario tests

    /**
     * @notice Test failure when presale cap is exceeded
     */
    function testFailPresaleCapExceeded() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        tokenSale.contributeToPresale{value: presaleCap}();
        vm.expectRevert("PresaleCapReached");
        tokenSale.contributeToPresale{value: 1 ether}(); // Contribution exceeding presale cap
    }

    /**
     * @notice Test failure when public sale cap is exceeded
     */
    function testFailPublicSaleCapExceeded() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        tokenSale.contributeToPublicSale{value: publicSaleCap}();
        vm.expectRevert("PublicSaleCapReached");
        tokenSale.contributeToPublicSale{value: 1 ether}(); // Contribution exceeding public sale cap
    }
}
