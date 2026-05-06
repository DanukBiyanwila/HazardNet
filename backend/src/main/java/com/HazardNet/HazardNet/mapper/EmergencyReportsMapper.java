package com.HazardNet.HazardNet.mapper;
import com.HazardNet.HazardNet.dto.EmergencyReportsDto;
import com.HazardNet.HazardNet.entity.EmergencyReports;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import java.util.List;

@Mapper(componentModel = "spring")
public interface EmergencyReportsMapper {

    @Mapping(target = "userId", source = "user.id")
    EmergencyReportsDto toDto(EmergencyReports emergencyReports);

    @Mapping(target = "user", ignore = true)
    EmergencyReports toEntity(EmergencyReportsDto emergencyReportsDto);

    List<EmergencyReportsDto> toDtoList(List<EmergencyReports> emergencyReportsList);

    @Mapping(target = "user", ignore = true)
    void updateEmergencyReportsFromDto(EmergencyReportsDto dto, @MappingTarget EmergencyReports entity);

    List<EmergencyReports> toEntityList(List<EmergencyReportsDto> dtos);
}
