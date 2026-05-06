package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.HomeRiskStatusDto;
import com.HazardNet.HazardNet.entity.HomeRiskStatus;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface HomeRiskStatusMapper {

    @Mapping(target = "homeId", source = "home.id")
    HomeRiskStatusDto toDto(HomeRiskStatus homeRiskStatus);

    @Mapping(target = "home", ignore = true)
    HomeRiskStatus toEntity(HomeRiskStatusDto homeRiskStatusDto);

    List<HomeRiskStatusDto> toDtoList(List<HomeRiskStatus> homeRiskStatuses);

    void updateHomeRiskStatusFromDto(HomeRiskStatusDto dto, @MappingTarget HomeRiskStatus entity);

    List<HomeRiskStatus> toEntityList(List<HomeRiskStatusDto> dtos);

}