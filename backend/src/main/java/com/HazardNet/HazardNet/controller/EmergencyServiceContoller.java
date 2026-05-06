package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.EmergencyServiceDto;
import com.HazardNet.HazardNet.service.EmergencyServiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/emergency_service")
@CrossOrigin(origins = "*")
public class EmergencyServiceContoller {

    private final EmergencyServiceService emergencyServiceService;

    @PostMapping("/create")
    public ResponseEntity<EmergencyServiceDto> createEmergencyService(@RequestBody EmergencyServiceDto emergencyServiceDto) {
        System.out.println("Emergency Service Details: " + emergencyServiceDto);
        EmergencyServiceDto createdService = emergencyServiceService.createEmergencyService(emergencyServiceDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdService);
    }

    @GetMapping("/")
    public ResponseEntity<List<EmergencyServiceDto>> getAllEmergencyServices() {
        List<EmergencyServiceDto> services = emergencyServiceService.getAllEmergencyServices();
        return ResponseEntity.status(HttpStatus.OK).body(services);
    }

    @GetMapping("/{id}")
    public ResponseEntity<EmergencyServiceDto> getEmergencyServiceById(@PathVariable Long id) {
        EmergencyServiceDto service = emergencyServiceService.getEmergencyServiceById(id);
        return ResponseEntity.status(HttpStatus.OK).body(service);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EmergencyServiceDto> updateEmergencyService(@PathVariable Long id, @RequestBody EmergencyServiceDto emergencyServiceDto) {
        EmergencyServiceDto updatedService = emergencyServiceService.updateEmergencyService(id, emergencyServiceDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedService);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteEmergencyService(@PathVariable Long id) {
        Boolean isDeleted = emergencyServiceService.deleteEmergencyService(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}