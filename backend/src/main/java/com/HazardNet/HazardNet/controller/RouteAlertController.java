package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.RouteAlertDto;
import com.HazardNet.HazardNet.service.RouteAlertService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/route_alert")
@CrossOrigin(origins = "*")
public class RouteAlertController {

    private final RouteAlertService routeAlertService;


    @PostMapping(value = "/create")
    public ResponseEntity<RouteAlertDto> createRouteAlert(@RequestBody RouteAlertDto routeAlertDto) {
        System.out.println("Route Alert Details  :"  + routeAlertDto);

        RouteAlertDto createdAlert = routeAlertService.createRouteAlert(routeAlertDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdAlert);
    }



    @GetMapping("/")
    public ResponseEntity<List<RouteAlertDto>> getAllRouteAlerts() {
        List<RouteAlertDto> alerts = routeAlertService.getAllRouteAlerts();
        return ResponseEntity.status(HttpStatus.OK).body(alerts);
    }



    @GetMapping("/{id}")
    public ResponseEntity<RouteAlertDto> getRouteAlertById(@PathVariable Long id) {
        RouteAlertDto alert = routeAlertService.getRouteAlertById(id);
        return ResponseEntity.status(HttpStatus.OK).body(alert);
    }



    @PutMapping("/{id}")
    public ResponseEntity<RouteAlertDto> updateRouteAlert(@PathVariable Long id, @RequestBody RouteAlertDto routeAlertDto) {
        RouteAlertDto updatedAlert = routeAlertService.updateRouteAlert(id, routeAlertDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedAlert);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteRouteAlert(@PathVariable Long id) {
        Boolean isDeleted = routeAlertService.deleteRouteAlert(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }

    @GetMapping("/by_user/{userId}")
    public ResponseEntity<List<RouteAlertDto>> getRouteAlertsByUserId(@PathVariable Long userId) {
        List<RouteAlertDto> alerts = routeAlertService.getRouteAlertsByUserId(userId);
        return ResponseEntity.status(HttpStatus.OK).body(alerts);
    }
}
