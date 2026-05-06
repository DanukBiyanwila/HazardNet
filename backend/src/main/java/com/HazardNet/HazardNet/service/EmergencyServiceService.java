package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.EmergencyServiceDto;
import java.util.List;

public interface EmergencyServiceService {

    EmergencyServiceDto createEmergencyService(EmergencyServiceDto emergencyServiceDto);

    List<EmergencyServiceDto> getAllEmergencyServices();

    EmergencyServiceDto getEmergencyServiceById(Long id);

    EmergencyServiceDto updateEmergencyService(Long id, EmergencyServiceDto emergencyServiceDto);

    Boolean deleteEmergencyService(Long id);
}