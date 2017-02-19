This file contains a variant of the "owned" pattern which requires the recipient to "claim" ownership.

Recommend choosing a different name as "owned" is mostly homesteaded as a primitive with a different interface.

    pragma solidity ^0.4.4;

Recommend updating required compiler version.
    
    /**
     * @title Owned contract with safe ownership pass.
     *
     * Note: all the non constant functions return false instead of throwing in case if state change
     * didn't happen yet.
     */

Generally concerned about not throwing on error, see discussion TODO

    contract Owned {
        address public contractOwner;
        address public pendingContractOwner;
    
        function Owned() {
            contractOwner = msg.sender;
        }
    
        modifier onlyContractOwner() {
            if (contractOwner == msg.sender) {
                _;
            }
        }

Note silent pass-through at end of `onlyContractOwner` modifier. 

    
        /**
         * Prepares ownership pass.
         *
         * Can only be called by current owner.
         *
         * @param _to address of the next owner.
         *
         * @return success.
         */
        function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
            pendingContractOwner = _to;
            return true;
        }

Note silent return false on modifier fail.
    
        /**
         * Finalize ownership pass.
         *
         * Can only be called by pending owner.
         *
         * @return success.
         */
        function claimContractOwnership() returns(bool) {
            if (pendingContractOwner != msg.sender) {
                return false;
            }
            contractOwner = pendingContractOwner;
            delete pendingContractOwner;
            return true;
        }
    }


