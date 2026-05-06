package com.HazardNet.HazardNet.mapper;

import com.HazardNet.HazardNet.dto.RoleDto;
import com.HazardNet.HazardNet.entity.Role;
import com.HazardNet.HazardNet.entity.User;
import org.mapstruct.*;
import org.mapstruct.factory.Mappers;

import java.util.List;

@Mapper(componentModel = "spring")
public interface RoleMapper {
    RoleMapper INSTANCE = Mappers.getMapper(RoleMapper.class);

    @Mapping(source = "users", target = "userIds")
    RoleDto toDto(Role role);

    Role toEntity(RoleDto roleDto);

    List<RoleDto> toDtoList(List<Role> roles);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "users", ignore = true)
    void updateRoleFromDto(RoleDto dto, @MappingTarget Role entity);

    List<Role> toEntityList(List<RoleDto> roleDtos);

    default List<Long> mapUsersToUserIds(List<User> users) {
        if (users == null) return List.of();
        return users.stream()
                .map(User::getId)
                .toList();
    }

}
