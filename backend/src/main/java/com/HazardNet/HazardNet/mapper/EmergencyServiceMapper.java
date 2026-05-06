package com.HazardNet.HazardNet.mapper;

import com.HazardNet.HazardNet.dto.EmergencyServiceDto;
import com.HazardNet.HazardNet.entity.EmergencyService;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

import java.util.List;

@Mapper(componentModel = "spring")
public interface EmergencyServiceMapper {

    EmergencyServiceDto toDto(EmergencyService emergencyService);

    EmergencyService toEntity(EmergencyServiceDto emergencyServiceDto);

    List<EmergencyServiceDto> toDtoList(List<EmergencyService> emergencyServices);

    void updateEmergencyServiceFromDto(EmergencyServiceDto dto, @MappingTarget EmergencyService entity);

    List<EmergencyService> toEntityList(List<EmergencyServiceDto> dtos);
}