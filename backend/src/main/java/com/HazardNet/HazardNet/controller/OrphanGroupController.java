package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.OrphanGroupDto;
import com.HazardNet.HazardNet.service.OrphanGroupService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/orphan_group")
@CrossOrigin(origins = "*")
public class OrphanGroupController {

    private final OrphanGroupService orphanGroupService;

    @PostMapping("/create")
    public ResponseEntity<OrphanGroupDto> createOrphanGroup(@RequestBody OrphanGroupDto orphanGroupDto) {
        System.out.println("Orphan Group Details : " + orphanGroupDto);
        OrphanGroupDto createdGroup = orphanGroupService.createOrphanGroup(orphanGroupDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdGroup);
    }

    @GetMapping("/")
    public ResponseEntity<List<OrphanGroupDto>> getAllOrphanGroups() {
        List<OrphanGroupDto> groups = orphanGroupService.getAllOrphanGroups();
        return ResponseEntity.status(HttpStatus.OK).body(groups);
    }

    @GetMapping("/{id}")
    public ResponseEntity<OrphanGroupDto> getOrphanGroupById(@PathVariable Long id) {
        OrphanGroupDto group = orphanGroupService.getOrphanGroupById(id);
        return ResponseEntity.status(HttpStatus.OK).body(group);
    }

    @PutMapping("/{id}")
    public ResponseEntity<OrphanGroupDto> updateOrphanGroup(@PathVariable Long id, @RequestBody OrphanGroupDto orphanGroupDto) {
        OrphanGroupDto updatedGroup = orphanGroupService.updateOrphanGroup(id, orphanGroupDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedGroup);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteOrphanGroup(@PathVariable Long id) {
        Boolean isDeleted = orphanGroupService.deleteOrphanGroup(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }

    // Add this new endpoint
    @GetMapping("/by_rescue_camp_id/{rescueCampId}")
    public ResponseEntity<List<OrphanGroupDto>> getOrphanGroupsByRescueCampId(@PathVariable Long rescueCampId) {

        System.out.println("Fetching Orphan Groups for Rescue Camp ID: " + rescueCampId);

        List<OrphanGroupDto> groups = orphanGroupService.getOrphanGroupsByRescueCampId(rescueCampId);

        return ResponseEntity.status(HttpStatus.OK).body(groups);
    }
}