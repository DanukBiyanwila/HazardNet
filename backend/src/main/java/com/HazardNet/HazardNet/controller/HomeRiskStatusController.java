package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.HomeRiskStatusDto;
import com.HazardNet.HazardNet.service.HomeRiskStatusService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/home_risk_status")
@CrossOrigin(origins = "*")
public class HomeRiskStatusController {

    private final HomeRiskStatusService homeRiskStatusService;


    @PostMapping(value = "/create")
    public ResponseEntity<HomeRiskStatusDto> createHomeRiskStatus(@RequestBody HomeRiskStatusDto homeRiskStatusDto) {
        System.out.println("Home Risk Status Details  :"  + homeRiskStatusDto);

        HomeRiskStatusDto createdStatus = homeRiskStatusService.createHomeRiskStatus(homeRiskStatusDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdStatus);
    }



    @GetMapping("/")
    public ResponseEntity<List<HomeRiskStatusDto>> getAllHomeRiskStatuses() {
        List<HomeRiskStatusDto> statuses = homeRiskStatusService.getAllHomeRiskStatuses();
        return ResponseEntity.status(HttpStatus.OK).body(statuses);
    }



    @GetMapping("/{id}")
    public ResponseEntity<HomeRiskStatusDto> getHomeRiskStatusById(@PathVariable Long id) {
        HomeRiskStatusDto status = homeRiskStatusService.getHomeRiskStatusById(id);
        return ResponseEntity.status(HttpStatus.OK).body(status);
    }



    @PutMapping("/{id}")
    public ResponseEntity<HomeRiskStatusDto> updateHomeRiskStatus(@PathVariable Long id, @RequestBody HomeRiskStatusDto homeRiskStatusDto) {
        HomeRiskStatusDto updatedStatus = homeRiskStatusService.updateHomeRiskStatus(id, homeRiskStatusDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedStatus);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteHomeRiskStatus(@PathVariable Long id) {
        Boolean isDeleted = homeRiskStatusService.deleteHomeRiskStatus(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}