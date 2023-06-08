// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.15;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Script.sol";

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

contract Deploy is Script {

    DLT public dlt;

    function run() public returns (DLT dlt) {
        string memory wrappers = vm.readFile("test/mock/DLTWrappers.huff");
        HuffDeployer.config().with_args(bytes.concat(abi.encode("DualLayerToken"), abi.encode("DLT")));
        dlt = DLT(HuffDeployer.deploy_with_code("DLT", wrappers));
    }
}
