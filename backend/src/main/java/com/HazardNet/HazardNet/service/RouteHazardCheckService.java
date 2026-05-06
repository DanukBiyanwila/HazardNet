package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.RouteHazardCheckDto;

import java.util.List;

public interface RouteHazardCheckService {

    RouteHazardCheckDto createRouteHazardCheck(RouteHazardCheckDto routeHazardCheckDto);
    List<RouteHazardCheckDto> getAllRouteHazardChecks();
    RouteHazardCheckDto getRouteHazardCheckById(Long id);

    RouteHazardCheckDto updateRouteHazardCheck(Long id, RouteHazardCheckDto routeHazardCheckDto);

    Boolean deleteRouteHazardCheck(Long id);

}