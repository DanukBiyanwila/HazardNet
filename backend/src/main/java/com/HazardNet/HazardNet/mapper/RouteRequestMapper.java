package com.HazardNet.HazardNet.mapper;

import java.util.List;
import com.HazardNet.HazardNet.entity.RouteRequest;

import com.HazardNet.HazardNet.entity.RouteHazardCheck;
import com.HazardNet.HazardNet.dto.RouteRequestDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface RouteRequestMapper {

    @Mapping(target = "userId", source = "user.id")
    @Mapping(
            target = "routeHazardCheckIds",
            expression = "java(routeRequest.getRouteHazardChecks() == null ? null : " +
                    "routeRequest.getRouteHazardChecks().stream().map(r -> r.getId()).toList())"
    )
    RouteRequestDto toDto(RouteRequest routeRequest);

    @Mapping(target = "user", ignore = true)
    @Mapping(target = "routeHazardChecks", ignore = true) // still ignore for entity creation
    RouteRequest toEntity(RouteRequestDto routeRequestDto);

    List<RouteRequestDto> toDtoList(List<RouteRequest> routeRequests);

    void updateRouteRequestFromDto(RouteRequestDto dto, @MappingTarget RouteRequest entity);

    List<RouteRequest> toEntityList(List<RouteRequestDto> dtos);
}
