package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.DonationMatchDto;
import com.HazardNet.HazardNet.entity.Donation;
import com.HazardNet.HazardNet.entity.DonationMatch;
import com.HazardNet.HazardNet.entity.OrphanGroup;
import com.HazardNet.HazardNet.entity.RescueCamp;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.DonationMatchMapper;
import com.HazardNet.HazardNet.repository.DonationMatchRepository;
import com.HazardNet.HazardNet.repository.DonationRepository;
import com.HazardNet.HazardNet.repository.OrphanGroupRepository;
import com.HazardNet.HazardNet.repository.RescueCampRepository;
import com.HazardNet.HazardNet.service.DonationMatchService;

import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class DonationMatchServiceImpl implements DonationMatchService {

    private final DonationMatchRepository donationMatchRepository;
    private final DonationMatchMapper donationMatchMapper;
    private final DonationRepository donationRepository;
    private final OrphanGroupRepository orphanGroupRepository;
    private  final RescueCampRepository rescueCampRepository;


    @Override
    @Transactional
    public DonationMatchDto createDonationMatch(DonationMatchDto dto) {

        DonationMatch donationMatch = donationMatchMapper.toEntity(dto);

        OrphanGroup orphanGroup = orphanGroupRepository.findById(dto.getOrphanGroupId())
                .orElseThrow(() -> new NotFoundException(
                        "Orphan Group not found with ID: " + dto.getOrphanGroupId()));
        donationMatch.setOrphanGroup(orphanGroup);

        RescueCamp rescueCamp = rescueCampRepository.findById(dto.getRescueCampId())
                .orElseThrow(() -> new NotFoundException(
                        "Rescue Camp not found with ID: " + dto.getRescueCampId()));
        donationMatch.setRescueCamp(rescueCamp);

        if (dto.getDonationIds() != null && !dto.getDonationIds().isEmpty()) {

            List<Donation> donations = donationRepository.findAllById(dto.getDonationIds());

            if (donations.size() != dto.getDonationIds().size()) {
                throw new NotFoundException("Some donations not found");
            }

            for (Donation donation : donations) {
                donation.getDonationMatches().add(donationMatch);
            }

            donationMatch.setDonations(donations);
        }

        DonationMatch savedMatch = donationMatchRepository.save(donationMatch);

        return donationMatchMapper.toDto(savedMatch);
    }


    @Override
    @Transactional
    public List<DonationMatchDto> getAllDonationMatches() {
        List<DonationMatch> donationMatches = donationMatchRepository.findAll();
        return donationMatchMapper.toDtoList(donationMatches);
    }

    @Override
    @Transactional
    public DonationMatchDto getDonationMatchById(Long id) {
        DonationMatch donationMatch = donationMatchRepository.findByIdWithRelations(id)
                .orElseThrow(() -> new NotFoundException("Donation Match not found with ID: " + id));
        return donationMatchMapper.toDto(donationMatch);
    }



    @Override
    public DonationMatchDto updateDonationMatch(Long id, DonationMatchDto donationMatchDto) {

        DonationMatch existingDonationMatch = donationMatchRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Donation Match not found with ID: " + id));


        donationMatchMapper.updateDonationMatchFromDto(donationMatchDto, existingDonationMatch);


        DonationMatch savedDonationMatch = donationMatchRepository.save(existingDonationMatch);


        return donationMatchMapper.toDto(savedDonationMatch);
    }


    @Override
    public Boolean deleteDonationMatch(Long id) {

        if (!donationMatchRepository.existsById(id)) {
            throw new NotFoundException("Donation Match not found with ID: " + id);
        }

        donationMatchRepository.deleteById(id);

        return true;
    }
}