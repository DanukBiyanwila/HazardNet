package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.MediaVerificationDto;
import com.HazardNet.HazardNet.service.MediaVerificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/media_verification")
@CrossOrigin(origins = "*")
public class MediaVerificationController {

    private final MediaVerificationService mediaVerificationService;


    @PostMapping(value = "/create")
    public ResponseEntity<MediaVerificationDto> createMediaVerification(@RequestBody MediaVerificationDto mediaVerificationDto) {
        System.out.println("Media Verification Details  :"  + mediaVerificationDto);

        MediaVerificationDto createdVerification = mediaVerificationService.createMediaVerification(mediaVerificationDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdVerification);
    }



    @GetMapping("/")
    public ResponseEntity<List<MediaVerificationDto>> getAllMediaVerifications() {
        List<MediaVerificationDto> verifications = mediaVerificationService.getAllMediaVerifications();
        return ResponseEntity.status(HttpStatus.OK).body(verifications);
    }



    @GetMapping("/{id}")
    public ResponseEntity<MediaVerificationDto> getMediaVerificationById(@PathVariable Long id) {
        MediaVerificationDto verification = mediaVerificationService.getMediaVerificationById(id);
        return ResponseEntity.status(HttpStatus.OK).body(verification);
    }



    @PutMapping("/{id}")
    public ResponseEntity<MediaVerificationDto> updateMediaVerification(@PathVariable Long id, @RequestBody MediaVerificationDto mediaVerificationDto) {
        MediaVerificationDto updatedVerification = mediaVerificationService.updateMediaVerification(id, mediaVerificationDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedVerification);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteMediaVerification(@PathVariable Long id) {
        Boolean isDeleted = mediaVerificationService.deleteMediaVerification(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}