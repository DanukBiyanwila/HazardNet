package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.RescueCampDto;
import com.HazardNet.HazardNet.service.RescueCampService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/rescue_camp")
@CrossOrigin(origins = "*")
public class RescueCampController {

    private final RescueCampService rescueCampService;

    @PostMapping(value = "/create", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<RescueCampDto> createRescueCamp(
            @RequestPart("rescueCampDto") RescueCampDto rescueCampDto,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {
        System.out.println("Rescue Camp Details : " + rescueCampDto);
        RescueCampDto createdCamp = rescueCampService.createRescueCamp(rescueCampDto, imageFile);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdCamp);
    }

    @GetMapping("/")
    public ResponseEntity<List<RescueCampDto>> getAllRescueCamps() {
        List<RescueCampDto> camps = rescueCampService.getAllRescueCamps();
        return ResponseEntity.status(HttpStatus.OK).body(camps);
    }

    @GetMapping("/{id}")
    public ResponseEntity<RescueCampDto> getRescueCampById(@PathVariable Long id) {
        // Calls the service method you showed
        RescueCampDto camp = rescueCampService.getRescueCampById(id);
        return ResponseEntity.status(HttpStatus.OK).body(camp);
    }
    @PutMapping(value = "/{id}", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<RescueCampDto> updateRescueCamp(
            @PathVariable Long id,
            @RequestPart("rescueCampDto") RescueCampDto rescueCampDto,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {
        RescueCampDto updatedCamp = rescueCampService.updateRescueCamp(id, rescueCampDto, imageFile);
        return ResponseEntity.status(HttpStatus.OK).body(updatedCamp);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteRescueCamp(@PathVariable Long id) {
        Boolean isDeleted = rescueCampService.deleteRescueCamp(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}