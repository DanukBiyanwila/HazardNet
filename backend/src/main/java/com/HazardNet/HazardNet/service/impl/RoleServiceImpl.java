package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.RoleDto;
import com.HazardNet.HazardNet.entity.Role; // Assuming you have a Role entity
import com.HazardNet.HazardNet.exception.NotFoundException; // Reusing your custom exception
import com.HazardNet.HazardNet.mapper.RoleMapper;
import com.HazardNet.HazardNet.repository.RoleRepository;
import com.HazardNet.HazardNet.service.RoleService;
import lombok.RequiredArgsConstructor; // For constructor injection

import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;

    private final RoleMapper roleMapper;

    @Override
    public RoleDto createRole(RoleDto roleDto) {

        Role role = roleMapper.toEntity(roleDto);


        Role savedRole = roleRepository.save(role);

        return roleMapper.toDto(savedRole);
    }

    @Override
    public List<RoleDto> getAllRoles() {
        return roleMapper.toDtoList(roleRepository.findAll());
    }



    @Override
    public RoleDto getRoleById(Long id) {
        Role role = roleRepository.findByIdWithUsers(id)
                .orElseThrow(() -> new NotFoundException("Role not found with ID: " + id));
        return roleMapper.toDto(role);
    }


    @Override
    public RoleDto updateRole(Long id, RoleDto roleDto) {

        Role existingRole = roleRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Role not found with ID: " + id));


        roleMapper.updateRoleFromDto(roleDto, existingRole);


        Role savedRole = roleRepository.save(existingRole);


        return roleMapper.toDto(savedRole);
    }

    @Override
    public Boolean deleteRole(Long id) {
        if (!roleRepository.existsById(id)) {
            throw new NotFoundException("Role not found with ID: " + id);
        }
        roleRepository.deleteById(id);
        return true;
    }
}