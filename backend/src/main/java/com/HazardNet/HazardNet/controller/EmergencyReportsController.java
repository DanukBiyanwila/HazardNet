package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.EmergencyReportsDto;
import com.HazardNet.HazardNet.service.EmergencyReportsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/emergency_reports")
@CrossOrigin(origins = "*")
public class EmergencyReportsController {

    private final EmergencyReportsService emergencyReportsService;

    @PostMapping("/create")
    public ResponseEntity<EmergencyReportsDto> createEmergencyReport(@RequestBody EmergencyReportsDto emergencyReportsDto) {
        System.out.println("Emergency Report Details: " + emergencyReportsDto);
        EmergencyReportsDto createdReport = emergencyReportsService.createEmergencyReport(emergencyReportsDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReport);
    }

    @GetMapping("/")
    public ResponseEntity<List<EmergencyReportsDto>> getAllEmergencyReports() {
        List<EmergencyReportsDto> reports = emergencyReportsService.getAllEmergencyReports();
        return ResponseEntity.status(HttpStatus.OK).body(reports);
    }

    @GetMapping("/{id}")
    public ResponseEntity<EmergencyReportsDto> getEmergencyReportById(@PathVariable Long id) {
        EmergencyReportsDto report = emergencyReportsService.getEmergencyReportById(id);
        return ResponseEntity.status(HttpStatus.OK).body(report);
    }

    @PutMapping("/{id}")
    public ResponseEntity<EmergencyReportsDto> updateEmergencyReport(@PathVariable Long id, @RequestBody EmergencyReportsDto emergencyReportsDto) {
        EmergencyReportsDto updatedReport = emergencyReportsService.updateEmergencyReport(id, emergencyReportsDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedReport);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteEmergencyReport(@PathVariable Long id) {
        Boolean isDeleted = emergencyReportsService.deleteEmergencyReport(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}