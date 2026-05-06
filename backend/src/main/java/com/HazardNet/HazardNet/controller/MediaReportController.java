package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.MediaReportDto;
import com.HazardNet.HazardNet.service.MediaReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/media_report")
@CrossOrigin(origins = "*")
public class MediaReportController {

    private final MediaReportService mediaReportService;


    @PostMapping(value = "/create", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<MediaReportDto> createMediaReport(
            @RequestPart("report") MediaReportDto mediaReportDto,
            @RequestPart(value = "file", required = false) MultipartFile file) {

        System.out.println("Media Report Details  :"  + mediaReportDto);

        MediaReportDto createdReport = mediaReportService.createMediaReport(mediaReportDto, file);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdReport);
    }



    @GetMapping("/")
    public ResponseEntity<List<MediaReportDto>> getAllMediaReports() {
        List<MediaReportDto> reports = mediaReportService.getAllMediaReports();
        return ResponseEntity.status(HttpStatus.OK).body(reports);
    }



    @GetMapping("/{id}")
    public ResponseEntity<MediaReportDto> getMediaReportById(@PathVariable Long id) {
        MediaReportDto report = mediaReportService.getMediaReportById(id);
        return ResponseEntity.status(HttpStatus.OK).body(report);
    }



    @PutMapping("/{id}")
    public ResponseEntity<MediaReportDto> updateMediaReport(@PathVariable Long id, @RequestBody MediaReportDto mediaReportDto) {
        MediaReportDto updatedReport = mediaReportService.updateMediaReport(id, mediaReportDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedReport);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteMediaReport(@PathVariable Long id) {
        Boolean isDeleted = mediaReportService.deleteMediaReport(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}