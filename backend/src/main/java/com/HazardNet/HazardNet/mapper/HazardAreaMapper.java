package com.HazardNet.HazardNet.mapper;

import com.HazardNet.HazardNet.dto.HazardAreaDto;
import com.HazardNet.HazardNet.dto.UserDto;
import com.HazardNet.HazardNet.dto.UserSimpleDetailsDto;
import com.HazardNet.HazardNet.entity.HazardArea;
import com.HazardNet.HazardNet.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.factory.Mappers;

import java.util.List;

@Mapper(componentModel = "spring")
public interface HazardAreaMapper {
    HazardAreaMapper INSTANCE = Mappers.getMapper(HazardAreaMapper.class);

    HazardAreaDto toDto(HazardArea hazardArea);

    HazardArea toEntity(HazardAreaDto hazardAreaDto);

    List<HazardAreaDto> toDtoList(List<HazardArea> hazardAreas);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "users", ignore = true)
    void updateHazardAreaFromDto(HazardAreaDto dto,
                                 @MappingTarget HazardArea entity);


    List<HazardArea> toEntityList(List<HazardAreaDto> hazardAreaDtos);


    UserSimpleDetailsDto map(User user);

    // MapStruct will use the above method automatically
    List<UserSimpleDetailsDto> mapUsers(List<User> users);
}
