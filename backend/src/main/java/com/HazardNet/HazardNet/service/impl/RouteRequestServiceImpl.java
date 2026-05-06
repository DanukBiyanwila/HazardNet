package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.RouteRequestDto;
import com.HazardNet.HazardNet.entity.*;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.RouteRequestMapper;
import com.HazardNet.HazardNet.repository.*;
import com.HazardNet.HazardNet.service.GoogleDirectionService;
import com.HazardNet.HazardNet.service.PolylineService;
import com.HazardNet.HazardNet.service.RouteRequestService;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RouteRequestServiceImpl implements RouteRequestService {

    private final RouteRequestRepository routeRequestRepository;
    private final RouteRequestMapper routeRequestMapper;
    private final UserRepository userRepository;
    private final RouteHazardCheckRepository routeHazardCheckRepository;
    private final HazardAreaRepository hazardAreaRepository;
    private final RouteAlertRepository routeAlertRepository;
    private final GoogleDirectionService googleDirectionService;
    private final PolylineService polylineService;


    @Override
    public RouteRequestDto createRouteRequest(RouteRequestDto dto) {

        RouteRequest routeRequest = routeRequestMapper.toEntity(dto);
        routeRequest.setRequested_time(LocalDateTime.now());
        routeRequest.setStatus("pending");

        // attach user
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new NotFoundException("User not found"));
        routeRequest.setUser(user);

        RouteRequest savedRequest = routeRequestRepository.save(routeRequest);

        // Google Direction API logic
        String encodedPolyline = googleDirectionService.getPolyline(
                savedRequest.getStart_lat(), savedRequest.getStart_lon(),
                savedRequest.getEnd_lat(), savedRequest.getEnd_lon());

        boolean hasHazard = false;
        if (encodedPolyline != null) {
            List<double[]> points = polylineService.decode(encodedPolyline);
            List<HazardArea> hazardAreas = hazardAreaRepository.findAll();

            for (HazardArea hazard : hazardAreas) {
                double radius = 100.0; // default 1km
                try {
                    if (hazard.getRadius_meters() != null) {
                        radius = Double.parseDouble(hazard.getRadius_meters());
                    }
                } catch (NumberFormatException e) {
                    // fallback to default
                }

                for (double[] point : points) {
                    double distance = polylineService.calculateDistance(
                            point[0], point[1],
                            hazard.getLocation_lat(), hazard.getLocation_lon());

                    if (distance <= radius) {
                        hasHazard = true;
                        
                        // Create RouteHazardCheck
                        RouteHazardCheck check = new RouteHazardCheck();
                        check.setDetected_time(LocalDateTime.now());
                        check.setRisk_level(hazard.getSeverity_level());
                        check.setDistance_to_hazard_m(distance);
                        check.setHazardArea(hazard);
                        check.getRouteRequests().add(savedRequest);
                        
                        RouteHazardCheck savedCheck = routeHazardCheckRepository.save(check);
                        savedRequest.getRouteHazardChecks().add(savedCheck);

                        // Create RouteAlert
                        RouteAlert alert = new RouteAlert();
                        alert.setAlert_time(LocalDateTime.now());
                        alert.setMessage("Warning: Hazard " + hazard.getName() + " detected on your route!");
                        alert.setAlert_type("HAZARD");
                        alert.setIs_know(false);
                        alert.setUser(user);
                        alert.setRouteHazardCheck(savedCheck);
                        routeAlertRepository.save(alert);
                        
                        break; // Move to next hazard area after finding one point in this hazard
                    }
                }
            }
        }

        savedRequest.setStatus(hasHazard ? "alert" : "safe");
        RouteRequest finalSaved = routeRequestRepository.save(savedRequest);

        return routeRequestMapper.toDto(finalSaved);
    }


    @Override
    public List<RouteRequestDto> getAllRouteRequests() {

        List<RouteRequest> routeRequests = routeRequestRepository.findAll();


        return routeRequestMapper.toDtoList(routeRequests);
    }


    @Override
    public RouteRequestDto getRouteRequestById(Long id) {

        RouteRequest routeRequest = routeRequestRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Route Request not found with ID: " + id));


        return routeRequestMapper.toDto(routeRequest);
    }


    @Override
    public RouteRequestDto updateRouteRequest(Long id, RouteRequestDto routeRequestDto) {

        RouteRequest existingRouteRequest = routeRequestRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Route Request not found with ID: " + id));


        routeRequestMapper.updateRouteRequestFromDto(routeRequestDto, existingRouteRequest);


        RouteRequest savedRouteRequest = routeRequestRepository.save(existingRouteRequest);


        return routeRequestMapper.toDto(savedRouteRequest);
    }


    @Override
    public Boolean deleteRouteRequest(Long id) {

        if (!routeRequestRepository.existsById(id)) {
            throw new NotFoundException("Route Request not found with ID: " + id);
        }

        routeRequestRepository.deleteById(id);

        return true;
    }
}