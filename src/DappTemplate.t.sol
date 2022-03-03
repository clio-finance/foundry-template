// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.12;

import {DSTest} from "ds-test/test.sol";
import {DappTemplate} from "./DappTemplate.sol";

contract DappTemplateTest is DSTest {
    DappTemplate template;

    function setUp() public {
        template = new DappTemplate();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
