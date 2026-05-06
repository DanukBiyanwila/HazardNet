package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.DonationDto;
import com.HazardNet.HazardNet.service.DonationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/donation")
@CrossOrigin(origins = "*")
public class DonationController {

    private final DonationService donationService;


    @PostMapping(value = "/create")
    public ResponseEntity<DonationDto> createDonation(@RequestBody DonationDto donationDto) {
        System.out.println("Donation Details  :"  + donationDto);

        DonationDto createdDonation = donationService.createDonation(donationDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdDonation);
    }



    @GetMapping("/")
    public ResponseEntity<List<DonationDto>> getAllDonations() {
        List<DonationDto> donations = donationService.getAllDonations();
        return ResponseEntity.status(HttpStatus.OK).body(donations);
    }



    @GetMapping("/{id}")
    public ResponseEntity<DonationDto> getDonationById(@PathVariable Long id) {
        DonationDto donation = donationService.getDonationById(id);
        return ResponseEntity.status(HttpStatus.OK).body(donation);
    }



    @GetMapping("/by_user/{userId}")
    public ResponseEntity<List<DonationDto>> getDonationsByUserId(@PathVariable Long userId) {
        List<DonationDto> donations = donationService.getDonationsByUserId(userId);
        return ResponseEntity.status(HttpStatus.OK).body(donations);
    }



    @PutMapping("/{id}")
    public ResponseEntity<DonationDto> updateDonation(@PathVariable Long id, @RequestBody DonationDto donationDto) {
        DonationDto updatedDonation = donationService.updateDonation(id, donationDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedDonation);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteDonation(@PathVariable Long id) {
        Boolean isDeleted = donationService.deleteDonation(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}