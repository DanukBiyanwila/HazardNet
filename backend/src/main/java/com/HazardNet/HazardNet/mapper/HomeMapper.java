package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.HomeDto;
import com.HazardNet.HazardNet.entity.Home;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface HomeMapper {

    @Mapping(target = "userIds", ignore = true) // keep ignoring in mapper, we will set manually
    @Mapping(target = "homeRiskStatusIds", ignore = true) // same
    HomeDto toDto(Home home);

    @Mapping(target = "users", ignore = true)
    @Mapping(target = "riskStatuses", ignore = true)
    Home toEntity(HomeDto homeDto);

    List<HomeDto> toDtoList(List<Home> homes);

    void updateHomeFromDto(HomeDto dto, @MappingTarget Home entity);

    List<Home> toEntityList(List<HomeDto> dtos);

}