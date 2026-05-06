package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.MediaVerificationDto;
import com.HazardNet.HazardNet.entity.MediaVerification;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface MediaVerificationMapper {

    @Mapping(target = "userId", ignore = true)
    MediaVerificationDto toDto(MediaVerification mediaVerification);

    @Mapping(target = "user", ignore = true)
    MediaVerification toEntity(MediaVerificationDto mediaVerificationDto);

    List<MediaVerificationDto> toDtoList(List<MediaVerification> mediaVerifications);

    void updateMediaVerificationFromDto(MediaVerificationDto dto, @MappingTarget MediaVerification entity);

    List<MediaVerification> toEntityList(List<MediaVerificationDto> dtos);

}