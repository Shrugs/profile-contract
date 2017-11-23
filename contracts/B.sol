pragma solidity 0.4.18;

import './Profilable.sol';

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address addr) internal {
        role.bearer[addr] = true;
    }

    function remove(Role storage role, address addr) internal {
        role.bearer[addr] = false;
    }

    function check(Role storage role, address addr) view internal {
        require(hasRole(role, addr));
    }

    function hasRole(Role storage role, address addr) view internal returns (bool) {
        return role.bearer[addr];
    }
}

contract RBAC {
    using Roles for Roles.Role;
    // role name to Role registry
    mapping (string => Roles.Role) roles;

    function addRole(address addr, string roleName)
        internal
    {
        roles[roleName].add(addr);
    }

    function removeRole(address addr, string roleName)
        internal
    {
        roles[roleName].remove(addr);
    }

    function checkRole(address addr, string roleName)
        view
        internal
    {
        roles[roleName].check(addr);
    }

    function hasRole(address addr, string roleName)
        view
        internal
        returns (bool)
    {
        return roles[roleName].hasRole(addr);
    }

    // when solidity supports dynamic arrays as arguments -_-
    // modifier onlyWithRoles(string[] roleNames) {
    //     bool hasAnyRole = false;
    //     for (uint8 i = 0; i < roleNames.length; i++) {
    //         if (hasRole(msg.sender, roleNames[i])) {
    //             hasAnyRole = true;
    //             break;
    //         }
    //     }

    //     require(hasAnyRole);

    //     _;
    // }
}

contract B is RBAC, Profilable {

    function profile()
        public
    {
        // adding and removal consumes memory so measure how much
        addRole(address(1), 'owner');
        addRole(address(1), 'advisor');

        addRole(address(2), 'owner');
        addRole(address(3), 'owner');
        addRole(address(4), 'advisor');
        addRole(address(5), 'advisor');
        addRole(address(6), 'advisor');

        // checking should be O(1)
        checkRole(address(1), 'owner');
        checkRole(address(1), 'advisor');
        checkRole(address(2), 'owner');
        require(!hasRole(address(2), 'advisor'));

        require(onlyOwnerOrAdvisor(address(1)));
        require(!onlyAdvisor(address(2)));
        require(onlyAdvisor(address(4)));
    }

    function onlyOwnerOrAdvisor(address addr)
        view
        internal
        returns(bool)
    {
        return hasRole(addr, 'owner') ||
               hasRole(addr, 'advisor');
    }

    function onlyAdvisor(address addr)
        view
        internal
        returns(bool)
    {
        return hasRole(addr, 'advisor');
    }
}
