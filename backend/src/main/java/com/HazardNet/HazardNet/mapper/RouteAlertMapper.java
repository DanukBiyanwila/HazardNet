package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.RouteAlertDto;
import com.HazardNet.HazardNet.entity.RouteAlert;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring", nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface RouteAlertMapper {

    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "routeHazardCheckId", source = "routeHazardCheck.id")
    RouteAlertDto toDto(RouteAlert routeAlert);

    @Mapping(target = "user", ignore = true)
    @Mapping(target = "routeHazardCheck", ignore = true)
    RouteAlert toEntity(RouteAlertDto dto);

    List<RouteAlertDto> toDtoList(List<RouteAlert> routeAlerts);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "user", ignore = true)
    @Mapping(target = "routeHazardCheck", ignore = true)
    void updateRouteAlertFromDto(RouteAlertDto dto, @MappingTarget RouteAlert entity);

    List<RouteAlert> toEntityList(List<RouteAlertDto> dtos);
}
