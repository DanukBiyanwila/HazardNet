package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.LocationResponseDTO;
import com.HazardNet.HazardNet.service.LocationService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/location")
@CrossOrigin(origins = "*")
public class LocationController {

    private final LocationService locationService;

    public LocationController(LocationService locationService) {
        this.locationService = locationService;
    }

    @GetMapping("/reverse")
    public LocationResponseDTO getLocation(
            @RequestParam double lat,
            @RequestParam double lng) {

        return locationService.getLocationDetails(lat, lng);
    }
}
