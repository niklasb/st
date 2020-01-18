pragma solidity ^0.5.0;

contract SharedBetweenProxyAndLogic {
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

    function proxyUpgrade(address _logic) public {
        require(logic == approvedLogic, "logic == approvedLogic");
        approvedLogic = address(0);
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    // from
    // https://github.com/zeppelinos/labs/blob/master/upgradeability_using_eternal_storage/contracts/Proxy.sol
    function () payable external {
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
