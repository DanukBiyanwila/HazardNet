package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.EmergencyServiceDto;
import com.HazardNet.HazardNet.entity.EmergencyService;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.EmergencyServiceMapper;
import com.HazardNet.HazardNet.repository.EmergencyServiceRepository;
import com.HazardNet.HazardNet.service.EmergencyServiceService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyServiceServiceImpl implements EmergencyServiceService {

    private final EmergencyServiceRepository emergencyServiceRepository;
    private final EmergencyServiceMapper emergencyServiceMapper;

    @Override
    public EmergencyServiceDto createEmergencyService(EmergencyServiceDto emergencyServiceDto) {
        EmergencyService emergencyService = emergencyServiceMapper.toEntity(emergencyServiceDto);
        EmergencyService savedService = emergencyServiceRepository.save(emergencyService);
        return emergencyServiceMapper.toDto(savedService);
    }

    @Override
    public List<EmergencyServiceDto> getAllEmergencyServices() {
        List<EmergencyService> services = emergencyServiceRepository.findAll();
        return emergencyServiceMapper.toDtoList(services);
    }

    @Override
    public EmergencyServiceDto getEmergencyServiceById(Long id) {
        EmergencyService emergencyService = emergencyServiceRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Emergency Service not found with ID: " + id));
        return emergencyServiceMapper.toDto(emergencyService);
    }

    @Override
    public EmergencyServiceDto updateEmergencyService(Long id, EmergencyServiceDto emergencyServiceDto) {
        EmergencyService existingService = emergencyServiceRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Emergency Service not found with ID: " + id));

        emergencyServiceMapper.updateEmergencyServiceFromDto(emergencyServiceDto, existingService);

        EmergencyService savedService = emergencyServiceRepository.save(existingService);
        return emergencyServiceMapper.toDto(savedService);
    }

    @Override
    public Boolean deleteEmergencyService(Long id) {
        if (!emergencyServiceRepository.existsById(id)) {
            throw new NotFoundException("Emergency Service not found with ID: " + id);
        }
        emergencyServiceRepository.deleteById(id);
        return true;
    }
}