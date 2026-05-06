package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.RouteHazardCheckDto;
import com.HazardNet.HazardNet.service.RouteHazardCheckService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/route_hazard_check")
@CrossOrigin(origins = "*")
public class RouteHazardCheckController {

    private final RouteHazardCheckService routeHazardCheckService;


    @PostMapping(value = "/create")
    public ResponseEntity<RouteHazardCheckDto> createRouteHazardCheck(@RequestBody RouteHazardCheckDto routeHazardCheckDto) {
        System.out.println("Route Hazard Check Details  :"  + routeHazardCheckDto);

        RouteHazardCheckDto createdCheck = routeHazardCheckService.createRouteHazardCheck(routeHazardCheckDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdCheck);
    }



    @GetMapping("/")
    public ResponseEntity<List<RouteHazardCheckDto>> getAllRouteHazardChecks() {
        List<RouteHazardCheckDto> checks = routeHazardCheckService.getAllRouteHazardChecks();
        return ResponseEntity.status(HttpStatus.OK).body(checks);
    }



    @GetMapping("/{id}")
    public ResponseEntity<RouteHazardCheckDto> getRouteHazardCheckById(@PathVariable Long id) {
        RouteHazardCheckDto check = routeHazardCheckService.getRouteHazardCheckById(id);
        return ResponseEntity.status(HttpStatus.OK).body(check);
    }



    @PutMapping("/{id}")
    public ResponseEntity<RouteHazardCheckDto> updateRouteHazardCheck(@PathVariable Long id, @RequestBody RouteHazardCheckDto routeHazardCheckDto) {
        RouteHazardCheckDto updatedCheck = routeHazardCheckService.updateRouteHazardCheck(id, routeHazardCheckDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedCheck);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteRouteHazardCheck(@PathVariable Long id) {
        Boolean isDeleted = routeHazardCheckService.deleteRouteHazardCheck(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}