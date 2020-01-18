pragma solidity ^0.5.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Token is IERC20 {
    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public decimals;

    struct TokenPartition {
        uint256 amount;
        uint64 returnDate;
    }

    struct Holder {
        address addr;
        TokenPartition[] tokenPartitions;
    }

    Holder[] holders;

    mapping (address => uint256) holderIdx;

    constructor() public {
        symbol = "TODO";
        name = "TODO";
        decimals = 18;
        holders.length = 1;
    }

    function totalSupply() external view returns (uint256) {
        // TODO
        return 0;
    }

    function balanceOf(address account) external view returns (uint256) {
        // TODO
        return 0;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        // TODO
        return false;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        // TODO
        return 0;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        // TODO
        return false;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        // TODO
        return false;
    }
}
