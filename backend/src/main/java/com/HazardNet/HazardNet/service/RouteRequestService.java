package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.RouteRequestDto;

import java.util.List;

public interface RouteRequestService {

    RouteRequestDto createRouteRequest(RouteRequestDto routeRequestDto);
    List<RouteRequestDto> getAllRouteRequests();
    RouteRequestDto getRouteRequestById(Long id);

    RouteRequestDto updateRouteRequest(Long id, RouteRequestDto routeRequestDto);

    Boolean deleteRouteRequest(Long id);

}