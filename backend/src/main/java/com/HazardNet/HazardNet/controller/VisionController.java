package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.service.VisionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/vision")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class VisionController {

    private final VisionService visionService;

    @PostMapping("/count-people")
    public ResponseEntity<Map<String, Integer>> countPeople(@RequestParam("file") MultipartFile file) {
        Integer count = visionService.countPeople(file);
        
        Map<String, Integer> response = new HashMap<>();
        response.put("peopleCount", count);
        
        return ResponseEntity.ok(response);
    }
}
