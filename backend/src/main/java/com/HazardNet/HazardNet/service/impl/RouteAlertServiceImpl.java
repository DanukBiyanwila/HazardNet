package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.RouteAlertDto;
import com.HazardNet.HazardNet.entity.RouteAlert;
import com.HazardNet.HazardNet.entity.RouteHazardCheck;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.RouteAlertMapper;
import com.HazardNet.HazardNet.repository.RouteAlertRepository;
import com.HazardNet.HazardNet.repository.RouteHazardCheckRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.RouteAlertService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class RouteAlertServiceImpl implements RouteAlertService {

    private final RouteAlertRepository routeAlertRepository;
    private final RouteAlertMapper routeAlertMapper;
    private final UserRepository userRepository;
    private final RouteHazardCheckRepository routeHazardCheckRepository;


    @Override
    public RouteAlertDto createRouteAlert(RouteAlertDto dto) {

        RouteAlert routeAlert = routeAlertMapper.toEntity(dto);

        // attach user
        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new NotFoundException("User not found"));

        routeAlert.setUser(user);
        user.getRouteAlerts().add(routeAlert);

        // attach route hazard check
        RouteHazardCheck hazardCheck = routeHazardCheckRepository
                .findById(dto.getRouteHazardCheckId())
                .orElseThrow(() -> new NotFoundException("Route Hazard Check not found"));

        routeAlert.setRouteHazardCheck(hazardCheck);
        hazardCheck.getRouteAlerts().add(routeAlert);

        RouteAlert saved = routeAlertRepository.save(routeAlert);

        return routeAlertMapper.toDto(saved);
    }


    @Override
    public List<RouteAlertDto> getAllRouteAlerts() {
        return routeAlertRepository.findAll().stream()
                .map(routeAlertMapper::toDto)
                .toList();
    }


    @Override
    public RouteAlertDto getRouteAlertById(Long id) {

        RouteAlert routeAlert = routeAlertRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Route Alert not found"));

        return routeAlertMapper.toDto(routeAlert);
    }


    @Override
    public RouteAlertDto updateRouteAlert(Long id, RouteAlertDto routeAlertDto) {

        RouteAlert existingRouteAlert = routeAlertRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Route Alert not found with ID: " + id));


        routeAlertMapper.updateRouteAlertFromDto(routeAlertDto, existingRouteAlert);


        RouteAlert savedRouteAlert = routeAlertRepository.save(existingRouteAlert);


        return routeAlertMapper.toDto(savedRouteAlert);
    }


    @Override
    public Boolean deleteRouteAlert(Long id) {

        if (!routeAlertRepository.existsById(id)) {
            throw new NotFoundException("Route Alert not found with ID: " + id);
        }

        routeAlertRepository.deleteById(id);

        return true;
    }

    @Override
    public List<RouteAlertDto> getRouteAlertsByUserId(Long userId) {
        return routeAlertRepository.findByUserId(userId).stream()
                .map(routeAlertMapper::toDto)
                .toList();
    }
}