pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/Spacebear.sol";

error OwnableUnauthorizedAccount(address account);

contract SpacebearsTest is Test {
 
    Spacebear spacebear;
    function setUp() public {
        spacebear = new Spacebear();
    }
 
    function testNameIsSpacebear() public {
        assertEq(spacebear.name(), "Spacebear");
    }

    function testMintingNFTs() public {
        spacebear.safeMint(msg.sender);
        assertEq(spacebear.ownerOf(0), msg.sender);
        assertEq(spacebear.tokenURI(0),  "https://ethereum-blockchain-developer.com/2022-06-nft-truffle-hardhat-foundry/nftdata/spacebear_1.json");
    }

    function testNFTCreationWrongOwner() public {
        vm.startPrank(address(0x1));
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(0x1)));
        spacebear.safeMint(address(0x1));
        vm.stopPrank();
    }

    function testNftBuyToken() public {
        vm.startPrank(address(0x1));
        spacebear.buyToken();
        vm.stopPrank();
        assertEq(spacebear.ownerOf(0), address(0x1));
    }
}
