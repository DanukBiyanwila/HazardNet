package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.HomeDto;
import com.HazardNet.HazardNet.service.HomeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/home")
@CrossOrigin(origins = "*")
public class HomeController {

    private final HomeService homeService;


    @PostMapping(value = "/create", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<HomeDto> createHome(
            @RequestPart("home") HomeDto homeDto,
            @RequestPart(value = "image", required = false) MultipartFile imageFile) {

        System.out.println("Home Details: " + homeDto);

        // Pass both the DTO and the file to the service
        HomeDto createdHome = homeService.createHome(homeDto, imageFile);

        return ResponseEntity.status(HttpStatus.CREATED).body(createdHome);
    }


    @GetMapping("/")
    public ResponseEntity<List<HomeDto>> getAllHomes() {
        List<HomeDto> homes = homeService.getAllHomes();
        return ResponseEntity.status(HttpStatus.OK).body(homes);
    }



    @GetMapping("/{id}")
    public ResponseEntity<HomeDto> getHomeById(@PathVariable Long id) {
        HomeDto home = homeService.getHomeById(id);
        return ResponseEntity.status(HttpStatus.OK).body(home);
    }



    @PutMapping("/{id}")
    public ResponseEntity<HomeDto> updateHome(@PathVariable Long id, @RequestBody HomeDto homeDto) {
        HomeDto updatedHome = homeService.updateHome(id, homeDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedHome);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteHome(@PathVariable Long id) {
        Boolean isDeleted = homeService.deleteHome(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }


    @GetMapping("/by_user/{userId}")
    public ResponseEntity<List<HomeDto>> getHomesByUserId(@PathVariable Long userId) {
        System.out.println("Fetching homes for User ID: " + userId);

        List<HomeDto> homes = homeService.getHomesByUserId(userId);

        return ResponseEntity.status(HttpStatus.OK).body(homes);
    }


}
