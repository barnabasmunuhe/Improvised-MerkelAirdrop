// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol"; //we are deploying the contract using the script to make sure the deployment is the same as in production

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    // ========== Storage for contracts to Deploy==========
    MerkleAirdrop public airdrop;
    BagelToken public token;

    // ========= Storage for test data ==========
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];
    address gasPayer;
    address user;
    uint256 userPrivateKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            // deploy with the script only if we are not on zkSync
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND); //minting some tokens to the owner of the token contract
            token.transfer(address(airdrop), AMOUNT_TO_SEND); //transferring some tokens to the airdrop contract
        }
        (user, userPrivateKey) = makeAddrAndKey("user"); //making an address with a private key
        //We gonna add the user address to the GenerateInput file and we create our input and
        // output files so we can get the proofs and expected merkle roots
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        // console.log("user address:", user);
        uint256 startingBalance = token.balanceOf(user);

        // messageDigest
        bytes32 messageDigest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        //sign the messageDigest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, messageDigest);

        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("ending balance:", endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testGasPayerCallsClaim() public {
        uint256 startingBalance = token.balanceOf(user);

        // messageDigest
        bytes32 messageDigest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        //sign the messageDigest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, messageDigest);

        //gasPayer calls the claim function on behalf of the user
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("ending balance:", endingBalance);

        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
