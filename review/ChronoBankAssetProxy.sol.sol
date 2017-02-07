pragma solidity ^0.4.4;

import "ChronoBankPlatform.sol";
import {ChronoBankAssetInterface as ChronoBankAsset} from "ChronoBankAssetInterface.sol";
import {ERC20Interface as ERC20} from "ERC20Interface.sol";

/**
 * @title ChronoBank Asset Proxy.
 *
 * Proxy implements ERC20 interface and acts as a gateway to a single platform asset.
 * Proxy adds symbol and caller(sender) when forwarding requests to platform.
 * Every request that is made by caller first sent to the specific asset implementation
 * contract, which then calls back to be forwarded onto platform.
 *
 * Calls flow: Caller ->
 *             Proxy.func(...) ->
 *             Asset.__func(..., Caller.address) ->
 *             Proxy.__func(..., Caller.address) ->
 *             Platform.proxyFunc(..., symbol, Caller.address)
 *
 * Asset implementation contract is mutable, but each user have an option to stick with
 * old implementation, through explicit decision made in timely manner, if he doesn't agree
 * with new rules.
 * Each user have a possibility to upgrade to latest asset contract implementation, without the
 * possibility to rollback.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn't happen yet.
 */
contract ChronoBankAssetProxy is ERC20 {
    // Assigned platform, immutable.
    ChronoBankPlatform public chronoBankPlatform;

    // Assigned symbol, immutable.
    bytes32 public symbol;

    // Assigned name, immutable.
    string public name;

    /**
     * Sets platform address, assigns symbol and name.
     *
     * Can be set only once.
     *
     * @param _chronoBankPlatform platform contract address.
     * @param _symbol assigned symbol.
     * @param _name assigned name.
     *
     * @return success.
     */
    function init(ChronoBankPlatform _chronoBankPlatform, bytes32 _symbol, string _name) returns(bool) {
        if (address(chronoBankPlatform) != 0x0) {
            return false;
        }
        chronoBankPlatform = _chronoBankPlatform;
        symbol = _symbol;
        name = _name;
        return true;
    }

    /**
     * Only platform is allowed to call.
     */
    modifier onlyChronoBankPlatform() {
        if (msg.sender == address(chronoBankPlatform)) {
            _;
        }
    }

    /**
     * Only current asset owner is allowed to call.
     */
    modifier onlyAssetOwner() {
        if (chronoBankPlatform.isOwner(msg.sender, symbol)) {
            _;
        }
    }

    /**
     * Returns asset implementation contract for current caller.
     *
     * @return asset implementation contract.
     */
    function _getAsset() internal returns(ChronoBankAsset) {
        return ChronoBankAsset(getVersionFor(msg.sender));
    }

    /**
     * Returns asset total supply.
     *
     * @return asset total supply.
     */
    function totalSupply() constant returns(uint) {
        return chronoBankPlatform.totalSupply(symbol);
    }

    /**
     * Returns asset balance for a particular holder.
     *
     * @param _owner holder address.
     *
     * @return holder balance.
     */
    function balanceOf(address _owner) constant returns(uint) {
        return chronoBankPlatform.balanceOf(_owner, symbol);
    }

    /**
     * Returns asset allowance from one holder to another.
     *
     * @param _from holder that allowed spending.
     * @param _spender holder that is allowed to spend.
     *
     * @return holder to spender allowance.
     */
    function allowance(address _from, address _spender) constant returns(uint) {
        return chronoBankPlatform.allowance(_from, _spender, symbol);
    }

    /**
     * Returns asset decimals.
     *
     * @return asset decimals.
     */
    function decimals() constant returns(uint8) {
        return chronoBankPlatform.baseUnit(symbol);
    }

    /**
     * Transfers asset balance from the caller to specified receiver.
     *
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     *
     * @return success.
     */
    function transfer(address _to, uint _value) returns(bool) {
        return _transferWithReference(_to, _value, "");
    }

    /**
     * Transfers asset balance from the caller to specified receiver adding specified comment.
     *
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in a platform's Transfer event.
     *
     * @return success.
     */
    function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
        return _transferWithReference(_to, _value, _reference);
    }

    /**
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @return success.
     */
    function _transferWithReference(address _to, uint _value, string _reference) internal returns(bool) {
        return _getAsset().__transferWithReference(_to, _value, _reference, msg.sender);
    }

    /**
     * Performs transfer call on the platform by the name of specified sender.
     *
     * Can only be called by asset implementation contract assigned to sender.
     *
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in a platform's Transfer event.
     * @param _sender initial caller.
     *
     * @return success.
     */
    function __transferWithReference(address _to, uint _value, string _reference, address _sender) onlyAccess(_sender) returns(bool) {
        return chronoBankPlatform.proxyTransferWithReference(_to, _value, symbol, _reference, _sender);
    }

    /**
     * Prforms allowance transfer of asset balance between holders.
     *
     * @param _from holder address to take from.
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     *
     * @return success.
     */
    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        return _transferFromWithReference(_from, _to, _value, "");
    }

    /**
     * Prforms allowance transfer of asset balance between holders adding specified comment.
     *
     * @param _from holder address to take from.
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in a platform's Transfer event.
     *
     * @return success.
     */
    function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool) {
        return _transferFromWithReference(_from, _to, _value, _reference);
    }

    /**
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @return success.
     */
    function _transferFromWithReference(address _from, address _to, uint _value, string _reference) internal returns(bool) {
        return _getAsset().__transferFromWithReference(_from, _to, _value, _reference, msg.sender);
    }

    /**
     * Performs allowance transfer call on the platform by the name of specified sender.
     *
     * Can only be called by asset implementation contract assigned to sender.
     *
     * @param _from holder address to take from.
     * @param _to holder address to give to.
     * @param _value amount to transfer.
     * @param _reference transfer comment to be included in a platform's Transfer event.
     * @param _sender initial caller.
     *
     * @return success.
     */
    function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) onlyAccess(_sender) returns(bool) {
        return chronoBankPlatform.proxyTransferFromWithReference(_from, _to, _value, symbol, _reference, _sender);
    }

    /**
     * Sets asset spending allowance for a specified spender.
     *
     * @param _spender holder address to set allowance to.
     * @param _value amount to allow.
     *
     * @return success.
     */
    function approve(address _spender, uint _value) returns(bool) {
        return _approve(_spender, _value);
    }

    /**
     * Resolves asset implementation contract for the caller and forwards there arguments along with
     * the caller address.
     *
     * @return success.
     */
    function _approve(address _spender, uint _value) internal returns(bool) {
        return _getAsset().__approve(_spender, _value, msg.sender);
    }

    /**
     * Performs allowance setting call on the platform by the name of specified sender.
     *
     * Can only be called by asset implementation contract assigned to sender.
     *
     * @param _spender holder address to set allowance to.
     * @param _value amount to allow.
     * @param _sender initial caller.
     *
     * @return success.
     */
    function __approve(address _spender, uint _value, address _sender) onlyAccess(_sender) returns(bool) {
        return chronoBankPlatform.proxyApprove(_spender, _value, symbol, _sender);
    }

    /**
     * Emits ERC20 Transfer event on this contract.
     *
     * Can only be, and, called by assigned platform when asset transfer happens.
     */
    function emitTransfer(address _from, address _to, uint _value) onlyChronoBankPlatform() {
        Transfer(_from, _to, _value);
    }

    /**
     * Emits ERC20 Approval event on this contract.
     *
     * Can only be, and, called by assigned platform when asset allowance set happens.
     */
    function emitApprove(address _from, address _spender, uint _value) onlyChronoBankPlatform() {
        Approval(_from, _spender, _value);
    }

    /**
     * Resolves asset implementation contract for the caller and forwards there transaction data,
     * along with the value. This allows for proxy interface growth.
     */
    function () payable {
        _getAsset().__process.value(msg.value)(msg.data, msg.sender);
    }

    /**
     * Indicates an upgrade freeze-time start, and the next asset implementation contract.
     */
    event UpgradeProposal(address newVersion);

    // Current asset implementation contract address.
    address latestVersion;

    // Proposed next asset implementation contract address.
    address pendingVersion;

    // Upgrade freeze-time start.
    uint pendingVersionTimestamp;

    // Timespan for users to review the new implementation and make decision.
    uint constant UPGRADE_FREEZE_TIME = 3 days;

    // Asset implementation contract address that user decided to stick with.
    // 0x0 means that user uses latest version.
    mapping(address => address) userOptOutVersion;

    /**
     * Only asset implementation contract assigned to sender is allowed to call.
     */
    modifier onlyAccess(address _sender) {
        if (getVersionFor(_sender) == msg.sender) {
            _;
        }
    }

    /**
     * Returns asset implementation contract address assigned to sender.
     *
     * @param _sender sender address.
     *
     * @return asset implementation contract address.
     */
    function getVersionFor(address _sender) constant returns(address) {
        return userOptOutVersion[_sender] == 0 ? latestVersion : userOptOutVersion[_sender];
    }

    /**
     * Returns current asset implementation contract address.
     *
     * @return asset implementation contract address.
     */
    function getLatestVersion() constant returns(address) {
        return latestVersion;
    }

    /**
     * Returns proposed next asset implementation contract address.
     *
     * @return asset implementation contract address.
     */
    function getPendingVersion() constant returns(address) {
        return pendingVersion;
    }

    /**
     * Returns upgrade freeze-time start.
     *
     * @return freeze-time start.
     */
    function getPendingVersionTimestamp() constant returns(uint) {
        return pendingVersionTimestamp;
    }

    /**
     * Propose next asset implementation contract address.
     *
     * Can only be called by current asset owner.
     *
     * Note: freeze-time should not be applied for the initial setup.
     *
     * @param _newVersion asset implementation contract address.
     *
     * @return success.
     */
    function proposeUpgrade(address _newVersion) onlyAssetOwner() returns(bool) {
        // Should not already be in the upgrading process.
        if (pendingVersion != 0x0) {
            return false;
        }
        // New version address should be other than 0x0.
        if (_newVersion == 0x0) {
            return false;
        }
        // Don't apply freeze-time for the initial setup.
        if (latestVersion == 0x0) {
            latestVersion = _newVersion;
            return true;
        }
        pendingVersion = _newVersion;
        pendingVersionTimestamp = now;
        UpgradeProposal(_newVersion);
        return true;
    }

    /**
     * Cancel the pending upgrade process.
     *
     * Can only be called by current asset owner.
     *
     * @return success.
     */
    function purgeUpgrade() onlyAssetOwner() returns(bool) {
        if (pendingVersion == 0x0) {
            return false;
        }
        delete pendingVersion;
        delete pendingVersionTimestamp;
        return true;
    }

    /**
     * Finalize an upgrade process setting new asset implementation contract address.
     *
     * Can only be called after an upgrade freeze-time.
     *
     * @return success.
     */
    function commitUpgrade() returns(bool) {
        if (pendingVersion == 0x0) {
            return false;
        }
        if (pendingVersionTimestamp + UPGRADE_FREEZE_TIME > now) {
            return false;
        }
        latestVersion = pendingVersion;
        delete pendingVersion;
        delete pendingVersionTimestamp;
        return true;
    }

    /**
     * Disagree with proposed upgrade, and stick with current asset implementation
     * until further explicit agreement to upgrade.
     *
     * @return success.
     */
    function optOut() returns(bool) {
        if (userOptOutVersion[msg.sender] != 0x0) {
            return false;
        }
        userOptOutVersion[msg.sender] = latestVersion;
        return true;
    }

    /**
     * Implicitly agree to upgrade to current and future asset implementation upgrades,
     * until further explicit disagreement.
     *
     * @return success.
     */
    function optIn() returns(bool) {
        delete userOptOutVersion[msg.sender];
        return true;
    }
}
