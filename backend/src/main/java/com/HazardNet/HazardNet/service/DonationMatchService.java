package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.DonationMatchDto;

import java.util.List;

public interface DonationMatchService {

    DonationMatchDto createDonationMatch(DonationMatchDto donationMatchDto);
    List<DonationMatchDto> getAllDonationMatches();
    DonationMatchDto getDonationMatchById(Long id);

    DonationMatchDto updateDonationMatch(Long id, DonationMatchDto donationMatchDto);

    Boolean deleteDonationMatch(Long id);

}