package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.EmergencyReportsDto;
import com.HazardNet.HazardNet.dto.EmergencyServiceDto;
import com.HazardNet.HazardNet.dto.TrustedContactsDto;
import com.HazardNet.HazardNet.entity.EmergencyReports;
import com.HazardNet.HazardNet.entity.EmergencyService;
import com.HazardNet.HazardNet.entity.TrustedContacts;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.EmergencyReportsMapper;
import com.HazardNet.HazardNet.mapper.EmergencyServiceMapper;
import com.HazardNet.HazardNet.mapper.TrustedContactsMapper;
import com.HazardNet.HazardNet.repository.EmergencyReportsRepository;
import com.HazardNet.HazardNet.repository.EmergencyServiceRepository;
import com.HazardNet.HazardNet.repository.TrustedContactsRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.EmergencyReportsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class EmergencyReportsServiceImpl implements EmergencyReportsService {

    private final EmergencyReportsRepository emergencyReportsRepository;
    private final EmergencyReportsMapper emergencyReportsmapper;
    private final UserRepository userRepository;
    private final EmergencyServiceRepository emergencyServiceRepository;
    private final EmergencyServiceMapper emergencyServiceMapper;
    private final TrustedContactsRepository trustedContactsRepository;
    private final TrustedContactsMapper trustedContactsMapper;

    @Override
    public EmergencyReportsDto createEmergencyReport(EmergencyReportsDto emergencyReportsDto) {

        // Optional: Auto-set created_at if it's missing from the request
        if (emergencyReportsDto.getCreated_at() == null) {
            emergencyReportsDto.setCreated_at(java.time.LocalDateTime.now().toString());
        }

        // Optional: Auto-set default status
        if (emergencyReportsDto.getStatus() == null) {
            emergencyReportsDto.setStatus("PENDING");
        }

        EmergencyReports emergencyReports = emergencyReportsmapper.toEntity(emergencyReportsDto);

        // Fetch and attach user
        if (emergencyReportsDto.getUserId() != null) {
            User user = userRepository.findById(emergencyReportsDto.getUserId())
                    .orElseThrow(() -> new NotFoundException("User not found with ID: " + emergencyReportsDto.getUserId()));
            emergencyReports.setUser(user);
        }

        EmergencyReports savedReport = emergencyReportsRepository.save(emergencyReports);
        EmergencyReportsDto resultDto = emergencyReportsmapper.toDto(savedReport);

        // 1. Find nearest Emergency Services (e.g., top 3 within range or just closest)
        List<EmergencyService> allServices = emergencyServiceRepository.findAll();
        List<EmergencyServiceDto> nearestServices = allServices.stream()
                .sorted(Comparator.comparingDouble(service -> calculateDistance(
                        emergencyReportsDto.getLocation_lat(),
                        emergencyReportsDto.getLocation_lon(),
                        service.getLocation_lat(),
                        service.getLocation_lon()
                )))
                .limit(3) // Top 3 nearest
                .map(emergencyServiceMapper::toDto)
                .collect(Collectors.toList());

        resultDto.setNearestServices(nearestServices);

        // 2. Fetch all Trusted Contacts for the user
        if (emergencyReportsDto.getUserId() != null) {
            List<TrustedContacts> contacts = trustedContactsRepository.findByUserId(emergencyReportsDto.getUserId());
            resultDto.setTrustedContacts(trustedContactsMapper.toDtoList(contacts));
        }

        return resultDto;
    }

    // Haversine formula for distance in kilometers
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Radius of the Earth in km
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    @Override
    public List<EmergencyReportsDto> getAllEmergencyReports() {
        List<EmergencyReports> reports = emergencyReportsRepository.findAll();
        return emergencyReportsmapper.toDtoList(reports);
    }

    @Override
    public EmergencyReportsDto getEmergencyReportById(Long id) {
        EmergencyReports emergencyReports = emergencyReportsRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Emergency Report not found with ID: " + id));
        return emergencyReportsmapper.toDto(emergencyReports);
    }

    @Override
    public EmergencyReportsDto updateEmergencyReport(Long id, EmergencyReportsDto emergencyReportsDto) {
        EmergencyReports existingReport = emergencyReportsRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Emergency Report not found with ID: " + id));

        emergencyReportsmapper.updateEmergencyReportsFromDto(emergencyReportsDto, existingReport);

        EmergencyReports savedReport = emergencyReportsRepository.save(existingReport);
        return emergencyReportsmapper.toDto(savedReport);
    }

    @Override
    public Boolean deleteEmergencyReport(Long id) {
        if (!emergencyReportsRepository.existsById(id)) {
            throw new NotFoundException("Emergency Report not found with ID: " + id);
        }
        emergencyReportsRepository.deleteById(id);
        return true;
    }
}