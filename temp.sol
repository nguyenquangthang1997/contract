import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/math.sol";
import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/safemath.sol";
import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/ierc20.sol";
import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/address.sol";
import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/safeERC20.sol";
import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/erc20.sol";
import "https://raw.githubusercontent.com/nguyenquangthang1997/contract/master/interface.sol";
pragma solidity 0.5.16;

contract Storage {

    address public governance;
    address public controller;

    constructor() public {
        governance = msg.sender;
    }

    modifier onlyGovernance() {
        require(isGovernance(msg.sender), "Not governance");
        _;
    }

    function setGovernance(address _governance) public onlyGovernance {
        require(_governance != address(0), "new governance shouldn't be empty");
        governance = _governance;
    }

    function setController(address _controller) public onlyGovernance {
        require(_controller != address(0), "new controller shouldn't be empty");
        controller = _controller;
    }

    function isGovernance(address account) public view returns (bool) {
        return account == governance;
    }

    function isController(address account) public view returns (bool) {
        return account == controller;
    }
}

// File: contracts/GovernableInit.sol

pragma solidity 0.5.16;



// A clone of Governable supporting the Initializable interface and pattern
contract GovernableInit is Initializable {

    bytes32 internal constant _STORAGE_SLOT = 0xa7ec62784904ff31cbcc32d09932a58e7f1e4476e1d041995b37c917990b16dc;

    modifier onlyGovernance() {
        require(Storage(_storage()).isGovernance(msg.sender), "Not governance");
        _;
    }

    constructor() public {
        assert(_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.governableInit.storage")) - 1));
    }

    function initialize(address _store) public initializer {
        _setStorage(_store);
    }

    function _setStorage(address newStorage) private {
        bytes32 slot = _STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            sstore(slot, newStorage)
        }
    }

    function setStorage(address _store) public onlyGovernance {
        require(_store != address(0), "new storage shouldn't be empty");
        _setStorage(_store);
    }

    function _storage() internal view returns (address str) {
        bytes32 slot = _STORAGE_SLOT;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            str := sload(slot)
        }
    }

    function governance() public view returns (address) {
        return Storage(_storage()).governance();
    }
}

// File: contracts/ControllableInit.sol

pragma solidity 0.5.16;


// A clone of Governable supporting the Initializable interface and pattern
contract ControllableInit is GovernableInit {

    constructor() public {
    }

    function initialize(address _storage) public initializer {
        GovernableInit.initialize(_storage);
    }

    modifier onlyController() {
        require(Storage(_storage()).isController(msg.sender), "Not a controller");
        _;
    }

    modifier onlyControllerOrGovernance(){
        require((Storage(_storage()).isController(msg.sender) || Storage(_storage()).isGovernance(msg.sender)),
            "The caller must be controller or governance");
        _;
    }

    function controller() public view returns (address) {
        return Storage(_storage()).controller();
    }
}
