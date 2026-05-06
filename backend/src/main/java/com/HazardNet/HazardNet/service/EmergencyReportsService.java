package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.EmergencyReportsDto;
import java.util.List;

public interface EmergencyReportsService {

    EmergencyReportsDto createEmergencyReport(EmergencyReportsDto emergencyReportsDto);

    List<EmergencyReportsDto> getAllEmergencyReports();

    EmergencyReportsDto getEmergencyReportById(Long id);

    EmergencyReportsDto updateEmergencyReport(Long id, EmergencyReportsDto emergencyReportsDto);

    Boolean deleteEmergencyReport(Long id);
}