pragma solidity ^0.5.0;

interface IProxy {
    function transferOwnership(address _newOwner) external;
    function proxyUpgrade(address newLogic) external;
    function logic() external view returns (address);
}

contract SharedBetweenProxyAndLogic is IProxy {
    address public owner;
    address public logic;
    address public approvedLogic;
    address public auditor;

    modifier onlyOwner {
        require(msg.sender == owner, "Sender must be owner");
        _;
    }
}

contract ContractLogic is SharedBetweenProxyAndLogic {
    function proxyUpgrade(address) external { revert(); }
    function transferOwnership(address) external { revert(); }
}

contract UpgradeProxy is SharedBetweenProxyAndLogic {
    constructor(address _owner, address _logic, address _auditor) public {
        owner = _owner;
        logic = _logic;
        auditor = _auditor;
    }

    function approveLogic(address _logic) public {
        require(msg.sender == auditor);
        approvedLogic = _logic;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // from
    // https://github.com/zeppelinos/labs/blob/master/upgradeability_using_eternal_storage/contracts/Proxy.sol
    function () payable external {
        require(logic == approvedLogic);
        approvedLogic = address(0);
        address impl = logic;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
