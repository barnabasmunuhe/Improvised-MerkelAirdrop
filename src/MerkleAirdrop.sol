// SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;

/*//////////////////////////////////////////////////////////////
                                IMPORTS
    //////////////////////////////////////////////////////////////*/
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    // I should have some list of addresses
    // allow someone in the list claim erc20 tokens
    bytes32 private immutable i_merkleRoot; // root of the merkle tree,You compute it off-chain when building your Merkle tree
    IERC20 private immutable i_airdropToken; // any ERC20 token being airdropped

    mapping(address claimer => bool claimed) private s_hasClaimed; //a way to track who has claimed

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)"); // EIP-712 typehash for the struct

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claim(address indexed account, uint256 amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("merkleAirdrop", "1") {
        i_merkleRoot = merkleRoot; //COMPUTED OFF-CHAIN
        i_airdropToken = airdropToken;
    }

    /**
     * @notice This function is what the airdrop receivers call in order to go through verification checks
     * For them to acquire the tokens they are claiming
     * @param account This is the account address claiming the airdrop token(s)
     * @param amount Represent the quantity of the airdrop token(s)
     * @param merkleProof A calldata bytes32 array  of the merkleProof the claimer MUST possess
     * @param v Used to retrieve the public key from r
     * @param r Any point on the secp256k1 curve Point G(Generator Point)
     * @param s Proofs if the signer really knows the private key
     */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        // check the signature
        // The Signature is independent of who calls the function
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // calculate using the account and the amount, the hash -> leaf node
        bytes32 leafNode = keccak256(bytes.concat(keccak256(abi.encode(account, amount)))); // this avoids collisions,
        // where you have two inputs that produce the same hash, hashing it twice ensures that the input is unique ***SECOND PRE-IMAGE ATTACK***

        // verify the leaf
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leafNode)) {
            revert MerkleAirdrop__InvalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        // transfer the tokens to the account
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4( //creating the structHash, is from EIP-712
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))) //creates the digest - struct hash
        );
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s); //allow the contract to gracefully manage invalid or
        // malformed signatures and revert with a specific, informative error rather than an abrupt, generic failure
        return actualSigner == account;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
