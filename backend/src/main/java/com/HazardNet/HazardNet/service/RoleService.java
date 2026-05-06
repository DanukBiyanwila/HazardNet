package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.RoleDto;
import com.HazardNet.HazardNet.dto.UserDto;

import java.util.List;

public interface RoleService {
    RoleDto createRole(RoleDto roleDto);

    List<RoleDto> getAllRoles();

    RoleDto getRoleById(Long id);

    RoleDto updateRole(Long id, RoleDto roleDto);

    Boolean deleteRole(Long id);


}
