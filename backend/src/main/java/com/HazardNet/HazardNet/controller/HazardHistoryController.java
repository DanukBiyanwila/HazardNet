package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.HazardHistoryDto;
import com.HazardNet.HazardNet.service.HazardHistoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/hazard_history") // Changed the base mapping
@CrossOrigin(origins = "*")
public class HazardHistoryController {

    private final HazardHistoryService hazardHistoryService;


    @PostMapping(value = "/create")
    public ResponseEntity<HazardHistoryDto> createHazardHistory(@RequestBody HazardHistoryDto hazardHistoryDto) {
        System.out.println("Hazard History Details  :"  + hazardHistoryDto);

        HazardHistoryDto createdHistory = hazardHistoryService.createHazardHistory(hazardHistoryDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdHistory);
    }



    @GetMapping("/")
    public ResponseEntity<List<HazardHistoryDto>> getAllHazardHistories() {
        List<HazardHistoryDto> histories = hazardHistoryService.getAllHazardHistories();
        return ResponseEntity.status(HttpStatus.OK).body(histories);
    }



    @GetMapping("/{id}")
    public ResponseEntity<HazardHistoryDto> getHazardHistoryById(@PathVariable Long id) {
        HazardHistoryDto history = hazardHistoryService.getHazardHistoryById(id);
        return ResponseEntity.status(HttpStatus.OK).body(history);
    }



    @PutMapping("/{id}")
    public ResponseEntity<HazardHistoryDto> updateHazardHistory(@PathVariable Long id, @RequestBody HazardHistoryDto hazardHistoryDto) {
        HazardHistoryDto updatedHistory = hazardHistoryService.updateHazardHistory(id, hazardHistoryDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedHistory);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteHazardHistory(@PathVariable Long id) {
        Boolean isDeleted = hazardHistoryService.deleteHazardHistory(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}