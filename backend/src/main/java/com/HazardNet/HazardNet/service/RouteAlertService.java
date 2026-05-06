package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.RouteAlertDto;

import java.util.List;

public interface RouteAlertService {

    RouteAlertDto createRouteAlert(RouteAlertDto routeAlertDto);
    List<RouteAlertDto> getAllRouteAlerts();
    RouteAlertDto getRouteAlertById(Long id);

    RouteAlertDto updateRouteAlert(Long id, RouteAlertDto routeAlertDto);

    Boolean deleteRouteAlert(Long id);

    List<RouteAlertDto> getRouteAlertsByUserId(Long userId);

}
