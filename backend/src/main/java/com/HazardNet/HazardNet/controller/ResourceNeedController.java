package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.ResourceNeedDto;
import com.HazardNet.HazardNet.service.ResourceNeedService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/resource_need")
@CrossOrigin(origins = "*")
public class ResourceNeedController {

    private final ResourceNeedService resourceNeedService;

    @PostMapping("/create")
    public ResponseEntity<ResourceNeedDto> createResourceNeed(@RequestBody ResourceNeedDto resourceNeedDto) {
        System.out.println("Resource Need Details : " + resourceNeedDto);
        ResourceNeedDto createdNeed = resourceNeedService.createResourceNeed(resourceNeedDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdNeed);
    }

    @GetMapping("/")
    public ResponseEntity<List<ResourceNeedDto>> getAllResourceNeeds() {
        List<ResourceNeedDto> needs = resourceNeedService.getAllResourceNeeds();
        return ResponseEntity.status(HttpStatus.OK).body(needs);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ResourceNeedDto> getResourceNeedById(@PathVariable Long id) {
        ResourceNeedDto need = resourceNeedService.getResourceNeedById(id);
        return ResponseEntity.status(HttpStatus.OK).body(need);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ResourceNeedDto> updateResourceNeed(@PathVariable Long id, @RequestBody ResourceNeedDto resourceNeedDto) {
        ResourceNeedDto updatedNeed = resourceNeedService.updateResourceNeed(id, resourceNeedDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedNeed);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteResourceNeed(@PathVariable Long id) {
        Boolean isDeleted = resourceNeedService.deleteResourceNeed(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}