package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.RoleDto;
import com.HazardNet.HazardNet.service.RoleService;
import com.HazardNet.HazardNet.service.impl.RoleServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

//import static java.lang.VersionProps.print;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/role")
@CrossOrigin(origins = "*")
public class RoleController {

    private final RoleService roleService;


    @PostMapping(value = "/create")
    public ResponseEntity<RoleDto> createRole(@RequestBody RoleDto roleDto) {
        System.out.println("Role Details  :"  + roleDto);

        return ResponseEntity.status(HttpStatus.CREATED).body( roleService.createRole(roleDto));
    }


    @GetMapping("/")
    public ResponseEntity<List<RoleDto>> getAllRoles() {
        return ResponseEntity.status(HttpStatus.OK).body(roleService.getAllRoles());
    }


    @GetMapping("/{id}")
    public ResponseEntity<RoleDto> getRoleById(@PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.OK).body(roleService.getRoleById(id));
    }


    @PutMapping("/{id}")
    public ResponseEntity<RoleDto> updateRole(@PathVariable Long id, @RequestBody RoleDto roleDto) {
        RoleDto updatedRole = roleService.updateRole(id, roleDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedRole);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteRole(@PathVariable Long id) {
        Boolean isDeleted = roleService.deleteRole(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}