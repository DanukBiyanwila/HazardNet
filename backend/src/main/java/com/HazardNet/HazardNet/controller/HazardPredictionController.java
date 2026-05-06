package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.HazardPredictionDto;
import com.HazardNet.HazardNet.service.HazardPredictionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/hazard_prediction") // Changed the base mapping
@CrossOrigin(origins = "*")
public class HazardPredictionController {

    private final HazardPredictionService hazardPredictionService;

    @PostMapping("/create")
    public ResponseEntity<HazardPredictionDto> createHazardPrediction(@RequestBody HazardPredictionDto hazardPredictionDto) {
        System.out.println("Hazard Prediction Details : " + hazardPredictionDto);
        HazardPredictionDto createdPrediction = hazardPredictionService.createHazardPrediction(hazardPredictionDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPrediction);
    }


    @GetMapping("/")
    public ResponseEntity<List<HazardPredictionDto>> getAllHazardPredictions() {
        List<HazardPredictionDto> predictions = hazardPredictionService.getAllHazardPredictions();
        return ResponseEntity.status(HttpStatus.OK).body(predictions);
    }


    @GetMapping("/{id}")
    public ResponseEntity<HazardPredictionDto> getHazardPredictionById(@PathVariable Long id) {
        HazardPredictionDto prediction = hazardPredictionService.getHazardPredictionById(id);
        return ResponseEntity.status(HttpStatus.OK).body(prediction);
    }


    @PutMapping("/{id}")
    public ResponseEntity<HazardPredictionDto> updateHazardPrediction(@PathVariable Long id, @RequestBody HazardPredictionDto hazardPredictionDto) {
        HazardPredictionDto updatedPrediction = hazardPredictionService.updateHazardPrediction(id, hazardPredictionDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedPrediction);
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteHazardPrediction(@PathVariable Long id) {
        Boolean isDeleted = hazardPredictionService.deleteHazardPrediction(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }


    //    get using python ML for flood
    @PostMapping("/create/flood/auto")
    public ResponseEntity<HazardPredictionDto> createHazardPredictionAuto(@RequestBody HazardPredictionDto hazardPredictionDto) {
        System.out.println("Controller received request: " + hazardPredictionDto);
        HazardPredictionDto createdPrediction = hazardPredictionService.createHazardPrediction_using_prediction_flood(hazardPredictionDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPrediction);
    }

    //    get using python ML for Landslide
    @PostMapping("/create/landslide/auto")
    public ResponseEntity<HazardPredictionDto> createHazardPredictionLandslideAuto(@RequestBody HazardPredictionDto hazardPredictionDto) {
        System.out.println("Controller received request for Landslide: " + hazardPredictionDto);
        HazardPredictionDto createdPrediction = hazardPredictionService.createHazardPrediction_using_prediction_landslide(hazardPredictionDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdPrediction);
    }
}