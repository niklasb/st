pragma solidity ^0.5.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Upgradeable.sol";

contract Token is IERC20, ContractLogic {

    using SafeMath for uint256;

    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    uint256 public constant maximumSupply = 50000000 ether;


    struct TokenPartition {
        uint256 amount;
        uint64 returnDate;
    }

    struct Holder {
        address addr;
        uint256 reclaimableAmount; //Amount (in euros) the holder is owed
        uint256 tokenPartitionIndex;
    }

    Holder[] holders;

    mapping (uint256 => TokenPartition[]) partitions;
    mapping (address => bool) whitelist;
    mapping (address => uint256) holderIdx;

    function construct() public onlyOwner {
        symbol = "BOND";
        name = "Legal Bond";
        decimals = 18;
        holders.length = 1;
    }
    function aquire(uint shareAmount, address investor) external returns (bool) {
        require(investor != address(0));
        require(whitelist[msg.sender], "investor not whitelisted");
        //Not handlig pre-purchases yet
        require(shareAmount <= 1000 ether, "less than minimum amount");
        // Edge cases possible if remaning available amount is less than 1000)
        if (_totalSupply.add(shareAmount) <= maximumSupply){
            shareAmount = maximumSupply.sub(_totalSupply);
        }
        require(IERC20(stableCoinAddress).transferFrom(investor, address(this), shareAmount), "token transfer failed");

        if(holders[holderIdx[investor]].addr == address(0)){
            holderIdx[investor] = holders.length;
            Holder memory hldr = Holder(investor, shareAmount, holderIdx[investor]);            
            holders.push(hldr);
        } else {
            Holder storage hodl = holders[holderIdx[investor]];
            partitions[hodl.tokenPartitionIndex].push(TokenPartition(shareAmount, uint64(now.div(1 days).add(14 days))));
        }
        require(holders.length <= 200, "Maximum investors reached");

        
        return true;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256 bal) {
        TokenPartition[] memory parts = partitions[holderIdx[msg.sender]];
        //we might reach the gas limit
        for(uint i= 0; i < parts.length; i++){
            bal += parts[i].amount;
        }
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(whitelist[recipient]);
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

    function _transfer(address sender, address recipient, uint256 amount) internal {
        TokenPartition[] storage _partitions = partitions[holderIdx[msg.sender]];
        if(_partitions[0].amount >= amount) {
            _partitions[0].amount = _partitions[0].amount.sub(amount);
            partitions[holderIdx[recipient]][0].amount = partitions[holderIdx[recipient]][0].amount.add(amount);
        } else {
            uint256 availableAmount = 0;
            for(uint i= 1; i < _partitions.length; i++){
                if(_partitions[i].returnDate <= now){
                    if(availableAmount + _partitions[i].amount >= amount){
                        uint256 remaning = amount.sub(availableAmount);
                        _partitions[i].amount = _partitions[i].amount.sub(remaning);
                        break;  
                    } else {
                        _partitions[i].amount = 0;
                        availableAmount += _partitions[i].amount;
                    }
                } else {
                    revert();
                }
            }
            partitions[holderIdx[recipient]][0].amount = partitions[holderIdx[recipient]][0].amount.add(amount);
        }
    }

    function addToWhitelist(address account) public
    {
        whitelist[account] = true;
    }


    function removeFromWhitelist(address account) public
    {
        whitelist[account] = false;
        terminateContract(account);
    }

    //Burn tokens owned by blacklisted holders. Track their reclaimable amount.
    function terminateContract(address account) public
    {
        uint256 tempReclaimableAmount;

        for (uint i = 0; i < partitions[holderIdx[account]].length; i++)
            {
                tempReclaimableAmount += partitions[holderIdx[account]][i].amount;
            }

        holders[holderIdx[account]].reclaimableAmount = tempReclaimableAmount;
        _burn(account, tempReclaimableAmount);

     }

    event dividendsPaid();
    address public stableCoinAddress;
    function payDividends() external onlyOwner {
        for (uint i = 0; i < holders.length; i++) {
            if (whitelist[holders[i].addr])
                IERC20(stableCoinAddress).transfer(holders[i].addr, balanceOf(holders[i].addr).mul(104).div(100));
        }
        emit dividendsPaid();

    }

    function _burn(address investor, uint256 amount) internal returns(bool){
        return true;
    }
}
