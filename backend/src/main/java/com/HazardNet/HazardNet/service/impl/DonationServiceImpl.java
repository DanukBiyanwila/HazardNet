package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.DonationDto;
import com.HazardNet.HazardNet.entity.Donation;
import com.HazardNet.HazardNet.entity.DonationMatch;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.DonationMapper;
import com.HazardNet.HazardNet.repository.DonationMatchRepository;
import com.HazardNet.HazardNet.repository.DonationRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.DonationService;

import java.util.List;

import com.HazardNet.HazardNet.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DonationServiceImpl implements DonationService {

    private final DonationRepository donationRepository;
    private final DonationMapper donationMapper;
    private final UserRepository userRepository;
    private final DonationMatchRepository donationMatchRepository;


    @Override
    public DonationDto createDonation(DonationDto donationDto) {

        Donation donation = donationMapper.toEntity(donationDto);

        // attach user
        User user = userRepository.findById(donationDto.getUserId())
                .orElseThrow(() -> new NotFoundException("User not found"));
        donation.setUser(user);
        user.getDonations().add(donation);

        // attach donation matches
        if (donationDto.getDonationMatchIds() != null) {
            List<DonationMatch> matches = donationDto.getDonationMatchIds().stream()
                    .map(id -> donationMatchRepository.findById(id)
                            .orElseThrow(() -> new NotFoundException("DonationMatch not found: " + id)))
                    .toList();
            donation.setDonationMatches(matches);
            matches.forEach(dm -> dm.getDonations().add(donation)); // bidirectional
        }

        Donation savedDonation = donationRepository.save(donation);

        DonationDto response = donationMapper.toDto(savedDonation);
        response.setUserId(user.getId());

        return response;
    }



    @Override
    public List<DonationDto> getAllDonations() {

        return donationRepository.findAll().stream().map(donation -> {

            DonationDto dto = donationMapper.toDto(donation);
            dto.setUserId(donation.getUser().getId());
            return dto;

        }).toList();

    }


    @Override
    public DonationDto getDonationById(Long id) {

        Donation donation = donationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Donation not found"));

        DonationDto dto = donationMapper.toDto(donation);
        dto.setUserId(donation.getUser().getId());

        dto.setDonationMatchIds(
                donation.getDonationMatches()
                        .stream()
                        .map(DonationMatch::getId)
                        .toList()
        );

        return dto;
    }


    @Override
    public DonationDto updateDonation(Long id, DonationDto donationDto) {

        Donation existingDonation = donationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Donation not found with ID: " + id));


        donationMapper.updateDonationFromDto(donationDto, existingDonation);


        Donation savedDonation = donationRepository.save(existingDonation);


        return donationMapper.toDto(savedDonation);
    }


    @Override
    public Boolean deleteDonation(Long id) {

        if (!donationRepository.existsById(id)) {
            throw new NotFoundException("Donation not found with ID: " + id);
        }

        donationRepository.deleteById(id);

        return true;
    }

    @Override
    public List<DonationDto> getDonationsByUserId(Long userId) {
        return donationRepository.findByUser_Id(userId).stream().map(donation -> {
            DonationDto dto = donationMapper.toDto(donation);
            dto.setUserId(donation.getUser().getId());
            dto.setDonationMatchIds(
                    donation.getDonationMatches()
                            .stream()
                            .map(DonationMatch::getId)
                            .toList()
            );
            return dto;
        }).toList();
    }
}