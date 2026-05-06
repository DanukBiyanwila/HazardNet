package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.DonationDto;

import java.util.List;

public interface DonationService {

    DonationDto createDonation(DonationDto donationDto);
    List<DonationDto> getAllDonations();
    DonationDto getDonationById(Long id);

    DonationDto updateDonation(Long id, DonationDto donationDto);

    Boolean deleteDonation(Long id);

    List<DonationDto> getDonationsByUserId(Long userId);

}