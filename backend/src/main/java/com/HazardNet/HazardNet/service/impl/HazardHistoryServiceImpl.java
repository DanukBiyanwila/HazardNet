package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.HazardAreaDto;
import com.HazardNet.HazardNet.dto.HazardHistoryDto;
import com.HazardNet.HazardNet.entity.HazardArea;
import com.HazardNet.HazardNet.entity.HazardHistory;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.HazardHistoryMapper;
import com.HazardNet.HazardNet.repository.HazardAreaRepository;
import com.HazardNet.HazardNet.repository.HazardHistoryRepository;
import com.HazardNet.HazardNet.service.HazardHistoryService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class HazardHistoryServiceImpl implements HazardHistoryService {

    private final HazardHistoryRepository hazardHistoryRepository;
    private final HazardHistoryMapper hazardHistoryMapper;
    private final HazardAreaRepository hazardAreaRepository;


    @Override
    public HazardHistoryDto createHazardHistory(HazardHistoryDto hazardHistoryDto) {

        HazardHistory hazardHistory = hazardHistoryMapper.toEntity(hazardHistoryDto);

        // Manually set hazardArea
        if (hazardHistoryDto.getHazardArea() != null && hazardHistoryDto.getHazardArea().getId() != null) {
            HazardArea hazardArea = hazardAreaRepository.findById(hazardHistoryDto.getHazardArea().getId())
                    .orElseThrow(() -> new RuntimeException("HazardArea not found"));
            hazardHistory.setHazardArea(hazardArea);
        }

        HazardHistory savedHazardHistory = hazardHistoryRepository.save(hazardHistory);

        return hazardHistoryMapper.toDto(savedHazardHistory);
    }


    @Override
    public List<HazardHistoryDto> getAllHazardHistories() {

        List<HazardHistory> hazardHistories = hazardHistoryRepository.findAll();


        return hazardHistoryMapper.toDtoList(hazardHistories);
    }


    @Override
    public HazardHistoryDto getHazardHistoryById(Long id) {

        HazardHistory hazardHistory = hazardHistoryRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Hazard History not found with ID: " + id));


        return hazardHistoryMapper.toDto(hazardHistory);
    }
    @Override
    public HazardHistoryDto updateHazardHistory(Long id, HazardHistoryDto hazardHistoryDto) {

        HazardHistory existing = hazardHistoryRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Hazard History not found with ID: " + id));

        // Map all simple fields except hazardArea
        hazardHistoryMapper.updateHazardHistoryFromDto(hazardHistoryDto, existing);

        // Only set hazardArea manually if a valid ID is provided
        HazardAreaDto hazardAreaDto = hazardHistoryDto.getHazardArea();
        if (hazardAreaDto != null && hazardAreaDto.getId() != null) {
            HazardArea hazardArea = hazardAreaRepository.findById(hazardAreaDto.getId())
                    .orElseThrow(() -> new NotFoundException("HazardArea not found with ID: " + hazardAreaDto.getId()));
            existing.setHazardArea(hazardArea);
        }

        // Save entity
        HazardHistory saved = hazardHistoryRepository.save(existing);

        // Return DTO
        return hazardHistoryMapper.toDto(saved);
    }



    @Override
    public Boolean deleteHazardHistory(Long id) {

        if (!hazardHistoryRepository.existsById(id)) {
            throw new NotFoundException("Hazard History not found with ID: " + id);
        }

        hazardHistoryRepository.deleteById(id);

        return true;
    }
}