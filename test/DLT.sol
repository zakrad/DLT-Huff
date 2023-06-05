// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract NonERC1155Recipient {}

contract DLTTest is Test {
    /// @dev Address of the DLT contract.
    DLT public dlt;

    /// @dev Setup the testing environment.
    function setUp() public {
        string memory wrappers = vm.readFile("test/DLTWrappers.huff");
        HuffDeployer.config().with_args(bytes.concat(abi.encode("Token"), abi.encode("TKN")));
        dlt = DLT(HuffDeployer.deploy_with_code("DLT", wrappers));
    }

    function testMintToEOA() public {
        uint256 mainId = 1;
        uint256 subId = 1;
        uint256 amount = 1;
        address eoa = address(0xbeef);

        dlt.mint(eoa, mainId, subId, amount, "");
        assertEq(dlt.subBalanceOf(eoa, mainId, subId), amount);
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
