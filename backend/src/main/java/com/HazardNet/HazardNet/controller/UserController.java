package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.AuthResponseDto;
import com.HazardNet.HazardNet.dto.LoginRequestDto;
import com.HazardNet.HazardNet.dto.UserDto;
import com.HazardNet.HazardNet.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/user")
@CrossOrigin(origins = "*")
public class UserController {
    private final UserService userService;


    // Create Users
    @PostMapping(value = "/create", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<UserDto> createUser(
            @RequestPart("user") UserDto userDto,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {
        System.out.println("User Details : "+ userDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(userService.createUser(userDto, imageFile));
    }

    // Get all Users
    @GetMapping("/")
    public ResponseEntity<List<UserDto>> getAllUsers() {
        return ResponseEntity.status(HttpStatus.OK).body(userService.getAllUsers());
    }

    // Get User by ID
    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUserById(@PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.OK).body(userService.getUserById(id));
    }

    // Update Users by ID
    @PutMapping("/{id}")
    public ResponseEntity<UserDto> updateUser(@PathVariable Long id, @RequestBody UserDto userDto) {
        return ResponseEntity.status(HttpStatus.OK).body(userService.updateUser(id, userDto));
    }

    // Delete Users by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteUser(@PathVariable Long id) {
        return ResponseEntity.status(HttpStatus.OK).body(userService.deleteUser(id));
    }

    // Add this to your UserController
    @PostMapping("/login")
    public ResponseEntity<AuthResponseDto> login(@RequestBody LoginRequestDto loginRequestDto) {
        AuthResponseDto response = userService.loginUser(loginRequestDto);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }


}
