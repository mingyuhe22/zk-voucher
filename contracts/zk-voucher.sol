// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "./verifier.sol";

contract ZkVoucher {
    Verifier public verifier;
    // following is a public key base on edd curve
    uint256 pubKeyX = 0x1a8d0f2;
    uint256 pubKeyY = 0x4d8374b;
    struct ZKP {
        uint256[2] a;
        uint256[2][2] b;
        uint256[2] c;
    }

    mapping(address => bool) public nullifier;

    constructor(address _verifier) {
        verifier = Verifier(_verifier);
    }

    function withdraw(ZKP memory zkp, uint256 amount) public {
        require(!nullifier[msg.sender], "Already used");
        uint256 addr = uint256(uint160(msg.sender));
        bool suc = verifier.verifyProof(
            zkp.a,
            zkp.b,
            zkp.c,
            [amount, addr, pubKeyX, pubKeyY]
        );
        if (suc) {
            nullifier[msg.sender] = true;
            payable(msg.sender).transfer(amount);
        }
    }
}
