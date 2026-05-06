package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.RouteHazardCheckDto;
import com.HazardNet.HazardNet.entity.RouteHazardCheck;
import com.HazardNet.HazardNet.entity.RouteRequest;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface RouteHazardCheckMapper {

    @Mapping(target = "hazardAreaId", source = "hazardArea.id")
    @Mapping(
            target = "routeRequestIds",
            expression = "java(routeHazardCheck.getRouteRequests() == null ? null : " +
                    "routeHazardCheck.getRouteRequests().stream().map(r -> r.getId()).toList())"
    )
    @Mapping(
            target = "routeAlertIds",
            expression = "java(routeHazardCheck.getRouteAlerts() == null ? null : " +
                    "routeHazardCheck.getRouteAlerts().stream().map(a -> a.getId()).toList())"
    )
    RouteHazardCheckDto toDto(RouteHazardCheck routeHazardCheck);

    @Mapping(target = "hazardArea", ignore = true)
    @Mapping(target = "routeAlerts", ignore = true)  // still ignore in entity creation
    @Mapping(target = "routeRequests", ignore = true)
    RouteHazardCheck toEntity(RouteHazardCheckDto dto);

    List<RouteHazardCheckDto> toDtoList(List<RouteHazardCheck> entities);

    void updateRouteHazardCheckFromDto(RouteHazardCheckDto dto, @MappingTarget RouteHazardCheck entity);

    List<RouteHazardCheck> toEntityList(List<RouteHazardCheckDto> dtos);
}
