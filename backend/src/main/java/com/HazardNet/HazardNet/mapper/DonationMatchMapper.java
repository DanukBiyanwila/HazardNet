package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.DonationMatchDto;
import com.HazardNet.HazardNet.entity.DonationMatch;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface DonationMatchMapper {

    @Mapping(target = "donationIds", expression = "java(donationMatch.getDonations().stream().map(com.HazardNet.HazardNet.entity.Donation::getId).toList())")
    @Mapping(target = "orphanGroupId", source = "orphanGroup.id")
    @Mapping(target = "rescueCampId", source = "rescueCamp.id")
    DonationMatchDto toDto(DonationMatch donationMatch);

    @Mapping(target = "donations", ignore = true)
    @Mapping(target = "orphanGroup", ignore = true)
    @Mapping(target = "rescueCamp", ignore = true)
    DonationMatch toEntity(DonationMatchDto donationMatchDto);

    List<DonationMatchDto> toDtoList(List<DonationMatch> donationMatches);

    void updateDonationMatchFromDto(DonationMatchDto dto, @MappingTarget DonationMatch entity);

    List<DonationMatch> toEntityList(List<DonationMatchDto> dtos);
}
