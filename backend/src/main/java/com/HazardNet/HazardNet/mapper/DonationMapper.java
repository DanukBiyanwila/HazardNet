package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.DonationDto;
import com.HazardNet.HazardNet.entity.Donation;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface DonationMapper {

    @Mapping(target = "userId", ignore = true)
    @Mapping(
            target = "donationMatchIds",
            expression = "java(donation.getDonationMatches() == null ? null : " +
                    "donation.getDonationMatches().stream().map(dm -> dm.getId()).toList())"
    )
    DonationDto toDto(Donation donation);

    @Mapping(target = "user", ignore = true)
    @Mapping(target = "donationMatches", ignore = true) // still ignore for entity creation
    Donation toEntity(DonationDto donationDto);

    List<DonationDto> toDtoList(List<Donation> donations);

    void updateDonationFromDto(DonationDto dto, @MappingTarget Donation entity);

    List<Donation> toEntityList(List<DonationDto> dtos);
}
