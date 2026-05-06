package com.HazardNet.HazardNet.mapper;

import com.HazardNet.HazardNet.dto.RoleDto;
import com.HazardNet.HazardNet.dto.RoleSimpleDetilsDto;
import com.HazardNet.HazardNet.dto.UserDto;
import com.HazardNet.HazardNet.entity.Role;
import com.HazardNet.HazardNet.entity.User;
import org.mapstruct.*;
import org.mapstruct.factory.Mappers;

import java.util.List;

@Mapper(componentModel = "spring", uses = {HazardAreaMapper.class})
public interface UserMapper {

    @Mapping(target = "hazardAreaDtos", source = "hazardAreas")
    @Mapping(target = "imageUrl", source = "imageUrl")
    UserDto toDto(User user);

    @Mapping(target = "hazardAreas", source = "hazardAreaDtos")
    @Mapping(target = "imageUrl", source = "imageUrl")
    User toEntity(UserDto userDto);

    List<UserDto> toDtoList(List<User> users);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    void updateUserFromDto(UserDto dto, @MappingTarget User entity);

    List<User> toEntityList(List<UserDto> dtos);


    default RoleSimpleDetilsDto map(Role role) {
        if (role == null) return null;

        RoleSimpleDetilsDto dto = new RoleSimpleDetilsDto();
        dto.setId(role.getId());
        dto.setName(role.getName());
        return dto;
    }
}
