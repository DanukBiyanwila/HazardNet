package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.HomeRiskStatusDto;
import com.HazardNet.HazardNet.entity.Home;
import com.HazardNet.HazardNet.entity.HomeRiskStatus;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.HomeRiskStatusMapper;
import com.HazardNet.HazardNet.repository.HomeRepository;
import com.HazardNet.HazardNet.repository.HomeRiskStatusRepository;
import com.HazardNet.HazardNet.service.HomeRiskStatusService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class HomeRiskStatusServiceImpl implements HomeRiskStatusService {

    private final HomeRiskStatusRepository homeRiskStatusRepository;
    private final HomeRiskStatusMapper homeRiskStatusMapper;
    private final HomeRepository homeRepository;

    @Override
    public HomeRiskStatusDto createHomeRiskStatus(HomeRiskStatusDto homeRiskStatusDto) {

        Home home = homeRepository.findById(homeRiskStatusDto.getHomeId())
                .orElseThrow(() -> new NotFoundException(
                        "Home not found with ID: " + homeRiskStatusDto.getHomeId()));

        HomeRiskStatus entity = homeRiskStatusMapper.toEntity(homeRiskStatusDto);
        entity.setHome(home);

        HomeRiskStatus saved = homeRiskStatusRepository.save(entity);

        return homeRiskStatusMapper.toDto(saved);
    }


    @Override
    public List<HomeRiskStatusDto> getAllHomeRiskStatuses() {

        List<HomeRiskStatus> homeRiskStatuses = homeRiskStatusRepository.findAll();


        return homeRiskStatusMapper.toDtoList(homeRiskStatuses);
    }


    @Override
    public HomeRiskStatusDto getHomeRiskStatusById(Long id) {

        HomeRiskStatus homeRiskStatus = homeRiskStatusRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Home Risk Status not found with ID: " + id));


        return homeRiskStatusMapper.toDto(homeRiskStatus);
    }


    @Override
    public HomeRiskStatusDto updateHomeRiskStatus(Long id, HomeRiskStatusDto homeRiskStatusDto) {

        HomeRiskStatus existingHomeRiskStatus = homeRiskStatusRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Home Risk Status not found with ID: " + id));


        homeRiskStatusMapper.updateHomeRiskStatusFromDto(homeRiskStatusDto, existingHomeRiskStatus);


        HomeRiskStatus savedHomeRiskStatus = homeRiskStatusRepository.save(existingHomeRiskStatus);


        return homeRiskStatusMapper.toDto(savedHomeRiskStatus);
    }


    @Override
    public Boolean deleteHomeRiskStatus(Long id) {

        if (!homeRiskStatusRepository.existsById(id)) {
            throw new NotFoundException("Home Risk Status not found with ID: " + id);
        }

        homeRiskStatusRepository.deleteById(id);

        return true;
    }

    @Override
    public List<HomeRiskStatusDto> getRiskStatusesByHome(Long homeId) {
        return homeRiskStatusMapper.toDtoList(
                homeRiskStatusRepository.findByHomeId(homeId)
        );
    }
}