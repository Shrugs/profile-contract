pragma solidity 0.4.18;

import './Profilable.sol';

library RoleRegistry {
    // mapping of address to bitfield of roles associated with them
    // so up to 32 unique roles. can reduce to uint8 for space savings
    struct Registry {
        mapping (address => uint32) roles;
    }

    // roleIds must be less than the amount of bits available in the field
    // @TODO(shrugs) - when we can use modifiers in libraries, switch this to a modifier
    // see: https://github.com/ethereum/solidity/issues/2467
    function validRoleId (uint8 roleId)
        pure
        internal
        returns (bool)
    {
        return roleId <= 32;
    }

    function mask(uint8 roleId)
        pure
        internal
        returns (uint32)
    {
        return uint32(1) << roleId;
    }

    function add(Registry storage registry, uint8 roleId, address addr)
        internal
    {
        assert(validRoleId(roleId));
        // flip the appropriate bit, keeping the others
        registry.roles[addr] |= mask(roleId);
    }

    function remove(Registry storage registry, uint8 roleId, address addr)
        internal
    {
        assert(validRoleId(roleId));
        // clear the appropriate bit, keeping the others
        registry.roles[addr] &= ~mask(roleId);
    }

    function check(Registry storage registry, uint8 roleId, address addr)
        view
        internal
    {
        assert(validRoleId(roleId));
        require(hasRole(registry, roleId, addr));
    }

    function hasRole(Registry storage registry, uint8 roleId, address addr)
        view
        internal
        returns (bool)
    {
        assert(validRoleId(roleId));
        return (registry.roles[addr] & mask(roleId)) > 0;
    }

    function hasAnyRoles(Registry storage registry, uint32 roleMask, address addr)
        view
        internal
        returns (bool)
    {
        return ((registry.roles[addr] & roleMask)) > 0;
    }
}

contract RBAC {
    using RoleRegistry for RoleRegistry.Registry;

    RoleRegistry.Registry roles;

    function addRole(address addr, uint8 roleId)
        internal
    {
        roles.add(roleId, addr);
    }

    function removeRole(address addr, uint8 roleId)
        internal
    {
        roles.remove(roleId, addr);
    }

    function checkRole(address addr, uint8 roleId)
        view
        internal
    {
        roles.check(roleId, addr);
    }

    function hasRole(address addr, uint8 roleId)
        view
        internal
        returns (bool)
    {
        return roles.hasRole(roleId, addr);
    }

    function hasAnyRoles(address addr, uint32 roleMask)
        view
        internal
        returns (bool)
    {
        return roles.hasAnyRoles(roleMask, addr);
    }
}


contract A is RBAC, Profilable {
    function profile()
        public
    {
        // adding and removal consumes memory so measure how much
        addRole(address(1), 1);
        addRole(address(1), 2);

        addRole(address(2), 1);
        addRole(address(3), 1);
        addRole(address(4), 2);
        addRole(address(5), 2);
        addRole(address(6), 2);

        // checking should be O(1)
        checkRole(address(1), 1);
        checkRole(address(1), 2);
        checkRole(address(2), 1);
        require(!hasRole(address(2), 2));

        require(hasAnyRoles(address(1), onlyOwnerOrAdvisorMask()));
        require(!hasAnyRoles(address(2), onlyAdvisorMask()));
        require(hasAnyRoles(address(4), onlyAdvisorMask()));
    }

    function onlyOwnerOrAdvisorMask() pure internal returns (uint32) {
        return RoleRegistry.mask(1) |
               RoleRegistry.mask(2);
    }

    function onlyAdvisorMask() pure internal returns (uint32) {
        return RoleRegistry.mask(2);
    }
}
