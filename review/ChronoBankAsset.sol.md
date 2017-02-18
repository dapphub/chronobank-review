The `ChronoBankAsset` contract is a base class for token contracts which are used via
a `ChronoBankAssetProxy`. In other terms, you could say that `ChronoBankAsset` is a 
**controller** or **implementation** for a token **frontend** or **interface** named `proxy`.

However, `ChronoBankAssetProxy` has substantial business logic related to call routing and version
upgrades, which makes understanding this contract on its own much more difficult, and the analogy
of "controller" is somewhat misleading.

This base implementation simply calls back to the `proxy`. TODO discuss this behavior.

The term "proxy" is one of the heavily overloaded terms in the Ethereum ecosystem. See
discussion about terminology TODO.

    pragma solidity ^0.4.4;

Bump this version.
    
    import "ChronoBankAssetInterface.sol";
    import {ChronoBankAssetProxyInterface as ChronoBankAssetProxy} from "ChronoBankAssetProxyInterface.sol";
    
    /**
     * @title ChronoBank Asset implementation contract.
     *
     * Basic asset implementation contract, without any additional logic.
     * Every other asset implementation contracts should derive from this one.
     * Receives calls from the proxy, and calls back immediatly without arguments modification.
     *
     * Note: all the non constant functions return false instead of throwing in case if state change
     * didn't happen yet.
     */
    contract ChronoBankAsset is ChronoBankAssetInterface {
        // Assigned asset proxy contract, immutable.
        ChronoBankAssetProxy public proxy;
    
        /**
         * Only assigned proxy is allowed to call.
         */
        modifier onlyProxy() {
            if (proxy == msg.sender) {
                _;
            }
        }
    
        /**
         * Sets asset proxy address.
         *
         * Can be set only once.
         *
         * @param _proxy asset proxy contract address.
         *
         * @return success.
         * @dev function is final, and must not be overridden.
         */
        function init(ChronoBankAssetProxy _proxy) returns(bool) {
            if (address(proxy) != 0x0) {
                return false;
            }
            proxy = _proxy;
            return true;
        }
    
        /**
         * Passes execution into virtual function.
         *
         * Can only be called by assigned asset proxy.
         *
         * @return success.
         * @dev function is final, and must not be overridden.
         */
        function __transferWithReference(address _to, uint _value, string _reference, address _sender) onlyProxy() returns(bool) {
            return _transferWithReference(_to, _value, _reference, _sender);
        }
    
        /**
         * Calls back without modifications.
         *
         * @return success.
         * @dev function is virtual, and meant to be overridden.
         */
        function _transferWithReference(address _to, uint _value, string _reference, address _sender) internal returns(bool) {
            return proxy.__transferWithReference(_to, _value, _reference, _sender);
        }
    
        /**
         * Passes execution into virtual function.
         *
         * Can only be called by assigned asset proxy.
         *
         * @return success.
         * @dev function is final, and must not be overridden.
         */
        function __transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) onlyProxy() returns(bool) {
            return _transferFromWithReference(_from, _to, _value, _reference, _sender);
        }
    
        /**
         * Calls back without modifications.
         *
         * @return success.
         * @dev function is virtual, and meant to be overridden.
         */
        function _transferFromWithReference(address _from, address _to, uint _value, string _reference, address _sender) internal returns(bool) {
            return proxy.__transferFromWithReference(_from, _to, _value, _reference, _sender);
        }
    
        /**
         * Passes execution into virtual function.
         *
         * Can only be called by assigned asset proxy.
         *
         * @return success.
         * @dev function is final, and must not be overridden.
         */
        function __approve(address _spender, uint _value, address _sender) onlyProxy() returns(bool) {
            return _approve(_spender, _value, _sender);
        }
    
        /**
         * Calls back without modifications.
         *
         * @return success.
         * @dev function is virtual, and meant to be overridden.
         */
        function _approve(address _spender, uint _value, address _sender) internal returns(bool) {
            return proxy.__approve(_spender, _value, _sender);
        }
    }