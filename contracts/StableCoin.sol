pragma solidity ^0.5.14;

import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StableCoin is ERC20, ERC20Detailed {
    constructor()
    external
    ERC20Detailed("IOUToken", "IOU", 18)
    {}

    function faucet() public {
        _mint(msg.sender, 1000**18);
    }
}