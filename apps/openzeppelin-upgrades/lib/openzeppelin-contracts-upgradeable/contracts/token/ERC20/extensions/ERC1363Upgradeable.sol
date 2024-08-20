// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "../ERC20Upgradeable.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC165Upgradeable} from "../../../utils/introspection/ERC165Upgradeable.sol";
import {IERC1363} from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import {ERC1363Utils} from "@openzeppelin/contracts/token/ERC20/utils/ERC1363Utils.sol";
import {Initializable} from "../../../proxy/utils/Initializable.sol";

/**
 * @title ERC1363
 * @dev Extension of {ERC20} tokens that adds support for code execution after transfers and approvals
 * on recipient contracts. Calls after transfers are enabled through the {ERC1363-transferAndCall} and
 * {ERC1363-transferFromAndCall} methods while calls after approvals can be made with {ERC1363-approveAndCall}
 */
abstract contract ERC1363Upgradeable is Initializable, ERC20Upgradeable, ERC165Upgradeable, IERC1363 {
    /**
     * @dev Indicates a failure within the {transfer} part of a transferAndCall operation.
     * @param receiver Address to which tokens are being transferred.
     * @param value Amount of tokens to be transferred.
     */
    error ERC1363TransferFailed(address receiver, uint256 value);

    /**
     * @dev Indicates a failure within the {transferFrom} part of a transferFromAndCall operation.
     * @param sender Address from which to send tokens.
     * @param receiver Address to which tokens are being transferred.
     * @param value Amount of tokens to be transferred.
     */
    error ERC1363TransferFromFailed(address sender, address receiver, uint256 value);

    /**
     * @dev Indicates a failure within the {approve} part of a approveAndCall operation.
     * @param spender Address which will spend the funds.
     * @param value Amount of tokens to be spent.
     */
    error ERC1363ApproveFailed(address spender, uint256 value);

    function __ERC1363_init() internal onlyInitializing {
    }

    function __ERC1363_init_unchained() internal onlyInitializing {
    }
    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165) returns (bool) {
        return interfaceId == type(IERC1363).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     *
     * Requirements:
     *
     * - The target has code (i.e. is a contract).
     * - The target `to` must implement the {IERC1363Receiver} interface.
     * - The target must return the {IERC1363Receiver-onTransferReceived} selector to accept the transfer.
     * - The internal {transfer} must succeed (returned `true`).
     */
    function transferAndCall(address to, uint256 value) public returns (bool) {
        return transferAndCall(to, value, "");
    }

    /**
     * @dev Variant of {transferAndCall} that accepts an additional `data` parameter with
     * no specified format.
     */
    function transferAndCall(address to, uint256 value, bytes memory data) public virtual returns (bool) {
        if (!transfer(to, value)) {
            revert ERC1363TransferFailed(to, value);
        }
        ERC1363Utils.checkOnERC1363TransferReceived(_msgSender(), _msgSender(), to, value, data);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the allowance mechanism
     * and then calls {IERC1363Receiver-onTransferReceived} on `to`.
     *
     * Requirements:
     *
     * - The target has code (i.e. is a contract).
     * - The target `to` must implement the {IERC1363Receiver} interface.
     * - The target must return the {IERC1363Receiver-onTransferReceived} selector to accept the transfer.
     * - The internal {transferFrom} must succeed (returned `true`).
     */
    function transferFromAndCall(address from, address to, uint256 value) public returns (bool) {
        return transferFromAndCall(from, to, value, "");
    }

    /**
     * @dev Variant of {transferFromAndCall} that accepts an additional `data` parameter with
     * no specified format.
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) public virtual returns (bool) {
        if (!transferFrom(from, to, value)) {
            revert ERC1363TransferFromFailed(from, to, value);
        }
        ERC1363Utils.checkOnERC1363TransferReceived(_msgSender(), from, to, value, data);
        return true;
    }

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens and then calls {IERC1363Spender-onApprovalReceived} on `spender`.
     *
     * Requirements:
     *
     * - The target has code (i.e. is a contract).
     * - The target `spender` must implement the {IERC1363Spender} interface.
     * - The target must return the {IERC1363Spender-onApprovalReceived} selector to accept the approval.
     * - The internal {approve} must succeed (returned `true`).
     */
    function approveAndCall(address spender, uint256 value) public returns (bool) {
        return approveAndCall(spender, value, "");
    }

    /**
     * @dev Variant of {approveAndCall} that accepts an additional `data` parameter with
     * no specified format.
     */
    function approveAndCall(address spender, uint256 value, bytes memory data) public virtual returns (bool) {
        if (!approve(spender, value)) {
            revert ERC1363ApproveFailed(spender, value);
        }
        ERC1363Utils.checkOnERC1363ApprovalReceived(_msgSender(), spender, value, data);
        return true;
    }
}
