// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "ds-test/test.sol";
import "../src/TokenSale.sol";
import "../src/ERC20Token.sol";

contract TokenSaleTest is DSTest, Test {
    TokenSale private tokenSale;
    ERC20Token private token;
    address private deployer;
    address private user1;
    uint256 private initialSupply = 10000 * 10**18;
    uint256 private presaleCap = 500 ether;
    uint256 private publicSaleCap = 1000 ether;

    function setUp() public {
        deployer = address(this);
        user1 = address(1);
        token = new ERC20Token(initialSupply);
        tokenSale = new TokenSale(
            address(token),
            presaleCap, 1 ether, 5 ether, block.timestamp + 1 days,
            publicSaleCap, 1 ether, 10 ether, block.timestamp + 2 days,
            200 ether, 500 ether
        );
        token.transfer(address(tokenSale), initialSupply);
    }

    function testInitialSetup() public {
        assertEq(tokenSale.presaleCap(), presaleCap);
        assertEq(tokenSale.publicSaleCap(), publicSaleCap);
        // Other initial state variables assertions
    }

    function testContributeToPresale() public {
        vm.warp(block.timestamp + 1 hours); // Warp to a time within presale period
        tokenSale.contributeToPresale{value: 2 ether}();
        assertEq(tokenSale.presaleTotalContributed(), 2 ether);
    }

    function testFailContributeToPresaleAfterEnd() public {
        vm.warp(block.timestamp + 2 days); // Warp to a time after presale period
        tokenSale.contributeToPresale{value: 2 ether}();
    }

    function testContributeToPublicSale() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // Warp to a time within public sale period
        tokenSale.contributeToPublicSale{value: 3 ether}();
        assertEq(tokenSale.publicSaleTotalContributed(), 3 ether);
    }

    function testFailContributeToPublicSaleBeforeStart() public {
        vm.warp(block.timestamp + 1 hours); // Before public sale starts
        tokenSale.contributeToPublicSale{value: 3 ether}();
    }

    function testDistributeTokensOnlyOwner() public {
        tokenSale.distributeTokens(user1, 100 ether);
        assertEq(token.balanceOf(user1), 100 ether);
    }

    function testFailDistributeTokensNotOwner() public {
        vm.prank(user1);
        tokenSale.distributeTokens(user1, 100 ether);
    }

    function testClaimRefund() public {
    // Step 1: Contribute to the public sale
    // Assuming public sale starts after presale ends and lasts for a certain duration
    uint256 publicSaleStartTime = tokenSale.presaleEndTime() + 1 hours;
    vm.warp(publicSaleStartTime); // Warp to public sale start
    uint256 contributionAmount = 1 ether; // Contribution amount (should be within limits)
    tokenSale.contributeToPublicSale{value: contributionAmount}(); 

    // Step 2: Ensure public sale ends
    uint256 publicSaleEndTime = tokenSale.publicSaleEndTime();
    vm.warp(publicSaleEndTime + 1 hours); // Warp to after public sale end

    // Step 3: Check public sale minimum cap not reached
    uint256 publicSaleMinCap = tokenSale.publicSaleMinCap();
    assert(tokenSale.publicSaleTotalContributed() < publicSaleMinCap, "Public sale minimum cap reached");

    // Step 4: Call `claimRefund()`
    uint256 initialBalance = address(this).balance;
    tokenSale.claimRefund();

    // Check if the refund was successful
    uint256 finalBalance = address(this).balance;
    assertEq(finalBalance, initialBalance + contributionAmount, "Refund was not successful");
    }


    function testFailClaimRefundMinCapReached() public {
        vm.warp(block.timestamp + 2 days + 1 hours); // After public sale ends
        // Setup scenario where min cap is reached
        tokenSale.claimRefund(); // Should fail
    }

    function testFailClaimRefundNoContribution() public {
        vm.warp(block.timestamp + 2 days + 1 hours); // After public sale ends
        vm.prank(user1); // An address with no contributions
        tokenSale.claimRefund(); // Should fail
    }

    // Edge case tests
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

    function testFailContributeOverPresaleMax() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        tokenSale.contributeToPresale{value: 6 ether}(); // More than 5 ether max
    }

    function testFailContributeOverPublicSaleMax() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        tokenSale.contributeToPublicSale{value: 11 ether}(); // More than 10 ether max
    }

    function testFailContributeUnderPresaleMin() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        tokenSale.contributeToPresale{value: 0.5 ether}(); // Less than 1 ether min
    }

    function testFailContributeUnderPublicSaleMin() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        tokenSale.contributeToPublicSale{value: 0.5 ether}(); // Less than 1 ether min
    }

    // Additional scenario tests
    function testFailPresaleCapExceeded() public {
        vm.warp(block.timestamp + 1 hours); // During presale
        tokenSale.contributeToPresale{value: presaleCap}();
        vm.expectRevert("PresaleCapReached");
        tokenSale.contributeToPresale{value: 1 ether}(); // Contribution exceeding presale cap
    }

    function testFailPublicSaleCapExceeded() public {
        vm.warp(block.timestamp + 1 days + 1 hours); // During public sale
        tokenSale.contributeToPublicSale{value: publicSaleCap}();
        vm.expectRevert("PublicSaleCapReached");
        tokenSale.contributeToPublicSale{value: 1 ether}(); // Contribution exceeding public sale cap
    }
}