package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.HazardAreaDto; // DTO for Hazard Area
import com.HazardNet.HazardNet.service.HazardAreaService; // Service interface
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/hazard_area") // Changed the request mapping
@CrossOrigin(origins = "*")
public class HazardAreaController {


    private final HazardAreaService hazardAreaService;

    @PostMapping(value = "/create")
    public ResponseEntity<HazardAreaDto> createHazardArea(@RequestBody HazardAreaDto hazardAreaDto) {
        System.out.println("HazardArea Details  :" + hazardAreaDto); // Logging the details

        HazardAreaDto createdHazardArea = hazardAreaService.createHazardArea(hazardAreaDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdHazardArea);
    }


    @GetMapping("/")
    public ResponseEntity<List<HazardAreaDto>> getAllHazardAreas() {
        List<HazardAreaDto> hazardAreas = hazardAreaService.getAllHazardAreas();
        return ResponseEntity.status(HttpStatus.OK).body(hazardAreas);
    }


    @GetMapping("/{id}")
    public ResponseEntity<HazardAreaDto> getHazardAreaById(@PathVariable Long id) {
        HazardAreaDto hazardArea = hazardAreaService.getHazardAreaById(id);
        return ResponseEntity.status(HttpStatus.OK).body(hazardArea);
    }


    @PutMapping("/{id}")
    public ResponseEntity<HazardAreaDto> updateHazardArea(@PathVariable Long id, @RequestBody HazardAreaDto hazardAreaDto) {
        HazardAreaDto updatedHazardArea = hazardAreaService.updateHazardArea(id, hazardAreaDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedHazardArea);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteHazardArea(@PathVariable Long id) {
        Boolean isDeleted = hazardAreaService.deleteHazardArea(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}