package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.RouteHazardCheckDto;
import com.HazardNet.HazardNet.entity.HazardArea;
import com.HazardNet.HazardNet.entity.RouteHazardCheck;
import com.HazardNet.HazardNet.entity.RouteRequest;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.RouteHazardCheckMapper;
import com.HazardNet.HazardNet.repository.HazardAreaRepository;
import com.HazardNet.HazardNet.repository.RouteHazardCheckRepository;
import com.HazardNet.HazardNet.repository.RouteRequestRepository;
import com.HazardNet.HazardNet.service.RouteHazardCheckService;

import java.util.List;

import com.HazardNet.HazardNet.service.RouteRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RouteHazardCheckServiceImpl implements RouteHazardCheckService {

    private final RouteHazardCheckRepository routeHazardCheckRepository;
    private final RouteHazardCheckMapper routeHazardCheckMapper;
    private final HazardAreaRepository hazardAreaRepository;
    private  final RouteRequestRepository routeRequestRepository;


    @Override
    public RouteHazardCheckDto createRouteHazardCheck(RouteHazardCheckDto dto) {

        RouteHazardCheck routeHazardCheck = routeHazardCheckMapper.toEntity(dto);

        // attach hazard area
        HazardArea hazardArea = hazardAreaRepository.findById(dto.getHazardAreaId())
                .orElseThrow(() -> new NotFoundException("Hazard Area not found"));

        routeHazardCheck.setHazardArea(hazardArea);
        hazardArea.getRouteHazardChecks().add(routeHazardCheck);

        if (dto.getRouteRequestIds() != null) {
            List<RouteRequest> routeRequests = dto.getRouteRequestIds().stream()
                    .map(id -> routeRequestRepository.findById(id)
                            .orElseThrow(() -> new NotFoundException("RouteRequest not found: " + id)))
                    .toList();

            routeHazardCheck.setRouteRequests(routeRequests);
            routeRequests.forEach(r -> r.getRouteHazardChecks().add(routeHazardCheck));
        }

        RouteHazardCheck saved = routeHazardCheckRepository.save(routeHazardCheck);

        return routeHazardCheckMapper.toDto(saved);
    }


    @Override
    public List<RouteHazardCheckDto> getAllRouteHazardChecks() {

        List<RouteHazardCheck> routeHazardChecks = routeHazardCheckRepository.findAll();


        return routeHazardCheckMapper.toDtoList(routeHazardChecks);
    }


    @Override
    public RouteHazardCheckDto getRouteHazardCheckById(Long id) {

        RouteHazardCheck routeHazardCheck = routeHazardCheckRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Route Hazard Check not found with ID: " + id));


        return routeHazardCheckMapper.toDto(routeHazardCheck);
    }


    @Override
    public RouteHazardCheckDto updateRouteHazardCheck(Long id, RouteHazardCheckDto routeHazardCheckDto) {

        RouteHazardCheck existingRouteHazardCheck = routeHazardCheckRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Route Hazard Check not found with ID: " + id));


        routeHazardCheckMapper.updateRouteHazardCheckFromDto(routeHazardCheckDto, existingRouteHazardCheck);


        RouteHazardCheck savedRouteHazardCheck = routeHazardCheckRepository.save(existingRouteHazardCheck);


        return routeHazardCheckMapper.toDto(savedRouteHazardCheck);
    }


    @Override
    public Boolean deleteRouteHazardCheck(Long id) {

        if (!routeHazardCheckRepository.existsById(id)) {
            throw new NotFoundException("Route Hazard Check not found with ID: " + id);
        }

        routeHazardCheckRepository.deleteById(id);

        return true;
    }
}