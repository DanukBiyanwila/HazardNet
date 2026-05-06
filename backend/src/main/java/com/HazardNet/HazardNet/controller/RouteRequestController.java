package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.RouteRequestDto;
import com.HazardNet.HazardNet.service.RouteRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/route_request")
@CrossOrigin(origins = "*")
public class RouteRequestController {

    private final RouteRequestService routeRequestService;


    @PostMapping(value = "/create")
    public ResponseEntity<RouteRequestDto> createRouteRequest(@RequestBody RouteRequestDto routeRequestDto) {
        System.out.println("Route Request Details  :"  + routeRequestDto);

        RouteRequestDto createdRequest = routeRequestService.createRouteRequest(routeRequestDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdRequest);
    }



    @GetMapping("/")
    public ResponseEntity<List<RouteRequestDto>> getAllRouteRequests() {
        List<RouteRequestDto> requests = routeRequestService.getAllRouteRequests();
        return ResponseEntity.status(HttpStatus.OK).body(requests);
    }



    @GetMapping("/{id}")
    public ResponseEntity<RouteRequestDto> getRouteRequestById(@PathVariable Long id) {
        RouteRequestDto request = routeRequestService.getRouteRequestById(id);
        return ResponseEntity.status(HttpStatus.OK).body(request);
    }



    @PutMapping("/{id}")
    public ResponseEntity<RouteRequestDto> updateRouteRequest(@PathVariable Long id, @RequestBody RouteRequestDto routeRequestDto) {
        RouteRequestDto updatedRequest = routeRequestService.updateRouteRequest(id, routeRequestDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedRequest);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteRouteRequest(@PathVariable Long id) {
        Boolean isDeleted = routeRequestService.deleteRouteRequest(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}