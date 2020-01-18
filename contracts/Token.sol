pragma solidity ^0.5.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Upgradeable.sol";

contract Token is IERC20, ContractLogic {

    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public const maximumSupply = 50000000 ether;

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

    function construct() public onlyOwner {
        symbol = "BOND";
        name = "Legal Bond";
        decimals = 18;
        holders.length = 1;
    }

    function aquire(uint shareAmount, address investor) external returns (uint256 shareAmount) {
        require(investor != address(0));
        require(whitelisted[msg.sender], "investor not whitelisted");
        //Not handlig pre-purchases yet
        require(shareAmount <= 1000 ether, "less than minimum amount");
        // Edge cases possible if remaning available amount is less than 1000)
        if (totalSupply.add(shareAmount) <= maximumSupply)){
            shareAmount = maximumSupply.sub(totalSupply);
        }
        require(stabletoken.transferFrom(investor, shareAmount), "token transfer failed");

        if(holderIdx[investor] == address(0)){
            holders.push({investor,[{0, 0}, {shareAmount, now.div(1 days).add(14 days)}]);
        } else {
            Holder storage hodl = holderIdx[address];
            hodl.tokenPartitions.push({shareAmount, now.div(1 days).add(14 days)});
        }
        require(holders.length <= 200, "Maximum investors reached")

        transferFrom(owner, investor, shareAmount);
    }

    function totalSupply() external view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address account) external view returns (uint256 bal) {
        uint bal = 0;
        TokenPartition[] memory partitions = holders[holderIdx[msg.sender]].tokenPartitions
        //we might reach the gas limit
        for(uint i= 0; i < partitions.length; i++){
            bal += partitions[i].amount;
        }
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(whitelisted[recipient]);
        _transfer(msg.sender, recipient, amount);
        return true;
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
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address _from, address _to, uint256 0) internal {
        TokenPartition[] memory partitions = holders[holderIdx[msg.sender]].tokenPartitions
        if(partitions[0].amount >= amount) {
            partitions[0] = partitions[0].amount.sub(amount);
            holders[holderIdx[recipient]].tokenPartitions[0].amount = holders[holderIdx[recipient]].tokenPartitions[0].amount.add(amount) 
        } else {
            uint256 availableAmount = 0;
            for(uint i= 1; i < partitions.length; i++){
                if(partitions[i].returnDate <= now){
                    if(availableAmount += partitions[i].amount >= amount){
                        uint256 remaning = amount.sub(availableAmount);
                        partitions[i].amount = partitions[i].amount.sub(remaning)
                        break;  
                    } else {
                        partitions[i].amount = 0;
                        availableAmount += partitions[i].amount
                    }
                } else {
                    revert();
                }
            }
            holders[holderIdx[recipient]].tokenPartitions[0].amount = holders[holderIdx[recipient]].tokenPartitions[0].amount.add(amount);
            holders[holderIdx[msg.sender]].tokenPartitions = partitions;//expensive operation 
        }
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

        for (uint i = 0; i < holders[holderIdx[account]].tokenPartitions.length; i++)
            {
                tempReclaimableAmount += holders[holderIdx[account]].tokenPartitions[i].amount;
            }

        holders[holderIdx[account]].reclaimableAmount = tempReclaimableAmount;
        holders[holderIdx[account]].tokenPartitions.length = 1;
        holders[holderIdx[account]].tokenPartitions[0].amount = 0;
        holders[holderIdx[account]].tokenPartitions[0].returnDate = 0;

        return 0;
    }

    event dividendsPaid();
    address public stableCoinAddress;
    function payDividends() external onlyOwner {
        for (uint i = 1; i < holders.length; i++) {
            if (whitelist[holders[i].addr])
                IERC20(stableCoinAddress).transfer(holders[i], balanceOf(holders[i]).mul(104).div(100));
        }
        emit dividendsPaid();

    }
}
