package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.DonationMatchDto;
import com.HazardNet.HazardNet.service.DonationMatchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RequiredArgsConstructor
@RestController
@RequestMapping("api/donation_match")
@CrossOrigin(origins = "*")
public class DonationMatchController {

    private final DonationMatchService donationMatchService;


    @PostMapping(value = "/create")
    public ResponseEntity<DonationMatchDto> createDonationMatch(@RequestBody DonationMatchDto donationMatchDto) {
        System.out.println("Donation Match Details  :"  + donationMatchDto);

        DonationMatchDto createdMatch = donationMatchService.createDonationMatch(donationMatchDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdMatch);
    }



    @GetMapping("/")
    public ResponseEntity<List<DonationMatchDto>> getAllDonationMatches() {
        List<DonationMatchDto> matches = donationMatchService.getAllDonationMatches();
        return ResponseEntity.status(HttpStatus.OK).body(matches);
    }



    @GetMapping("/{id}")
    public ResponseEntity<DonationMatchDto> getDonationMatchById(@PathVariable Long id) {
        DonationMatchDto match = donationMatchService.getDonationMatchById(id);
        return ResponseEntity.status(HttpStatus.OK).body(match);
    }



    @PutMapping("/{id}")
    public ResponseEntity<DonationMatchDto> updateDonationMatch(@PathVariable Long id, @RequestBody DonationMatchDto donationMatchDto) {
        DonationMatchDto updatedMatch = donationMatchService.updateDonationMatch(id, donationMatchDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedMatch);
    }



    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteDonationMatch(@PathVariable Long id) {
        Boolean isDeleted = donationMatchService.deleteDonationMatch(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }
}