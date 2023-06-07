// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

abstract contract DLTReceiver {
    function onDLTReceived(address, address, uint256, uint256, uint256, bytes calldata) external virtual returns (bytes4) {
        return DLTReceiver.onDLTReceived.selector;
    }
}

contract DLTRecipient is DLTReceiver {
    address public operator;
    address public from;
    uint256 public mainId;
    uint256 public subId;
    uint256 public amount;
    bytes public data;

    function onDLTReceived(
        address _operator,
        address _from,
        uint256 _mainId,
        uint256 _subId,
        uint256 _amount,
        bytes calldata _data
    ) public override returns (bytes4) {
        operator = _operator;
        from = _from;
        mainId = _mainId;
        subId = _subId;
        amount = _amount;
        data = _data;

        return DLTReceiver.onDLTReceived.selector;
    }
}

contract NonDLTRecipient {}

contract DLTTest is Test {
    /// @dev Address of the DLT contract.
    DLT public dlt;

    /// @dev Setup the testing environment.
    function setUp() public {
        string memory wrappers = vm.readFile("test/mock/DLTWrappers.huff");
        HuffDeployer.config().with_args(bytes.concat(abi.encode("DualLayerToken"), abi.encode("DLT")));
        dlt = DLT(HuffDeployer.deploy_with_code("DLT", wrappers));
    }

    function testNameAndSymbol() public {
        assertEq(keccak256(abi.encode(dlt.name())), keccak256(abi.encode("DualLayerToken")));
        assertEq(keccak256(abi.encode(dlt.symbol())), keccak256(abi.encode("DLT")));
    }

    function testMintToEOA() public {
        uint256 mainId = 1;
        uint256 subId = 2;
        uint256 amount = 1;
        address eoa = address(0xbeef);

        dlt.mint(eoa, mainId, subId, amount, "");
        assertEq(dlt.subBalanceOf(eoa, mainId, subId), amount);
    }

    function testMintDLTRecipient() public {
        DLTRecipient to = new DLTRecipient();
        dlt.mint(address(to), 1, 2, 1, "data");

        assertEq(dlt.subBalanceOf(address(to), 1, 2), 1);

        assertEq(to.operator(), address(this));
        assertEq(to.from(), address(0));
        assertEq(to.mainId(), 1);
        assertEq(to.subId(), 2);
        assertEq(to.data(), "data");
    }

    function testBurn() public {
        dlt.mint(address(0xBEEF), 1, 1, 10, "");

        dlt.burn(address(0xBEEF), 1, 1, 6);

        assertEq(dlt.subBalanceOf(address(0xBEEF), 1, 1), 4);
    }

}

interface DLT {
    function mint(address, uint256, uint256, uint256, bytes calldata) external;
    function burn(address, uint256, uint256, uint256) external;

    function isApprovedForAll(address, address) external view returns (bool);
    function setApprovalForAll(address, bool) external;

    function safeTransferFrom(address, address, uint256, uint256, uint256, bytes calldata) external;

    function subBalanceOf(address, uint256, uint256) external view returns (uint256);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}
