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
        uint256 reclaimableAmount; //Amount (in euros) the holder is owed
        TokenPartition[] tokenPartitions;
    }

    Holder[] holders;

    mapping (address => bool) whitelist;
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

    function addToWhitelist(address account)
    {
        whitelist[account] = true;
        return 0;
    }


    function removeFromWhitelist(address account)
    {
        whitelist[account] = false;
        terminateContract(account);
    }

    //Burn tokens owned by blacklisted holders. Track their reclaimable amount.
    function terminateContract(address account)
    {
        uint256 tempReclaimableAmount;

        for partition in holders[holderIdx[account]].tokenPartitions:
            tempReclaimableAmount+=amount;

        holders[holderIdx[account]].reclaimableAmount = tempReclaimableAmount;
        _burn(account, tempReclaimableAmount);

        return 0;
    }
}
