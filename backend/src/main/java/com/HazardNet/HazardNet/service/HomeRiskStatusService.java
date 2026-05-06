package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.HomeRiskStatusDto;

import java.util.List;

public interface HomeRiskStatusService {

    HomeRiskStatusDto createHomeRiskStatus(HomeRiskStatusDto homeRiskStatusDto);
    List<HomeRiskStatusDto> getAllHomeRiskStatuses();
    HomeRiskStatusDto getHomeRiskStatusById(Long id);

    HomeRiskStatusDto updateHomeRiskStatus(Long id, HomeRiskStatusDto homeRiskStatusDto);

    Boolean deleteHomeRiskStatus(Long id);

    List<HomeRiskStatusDto> getRiskStatusesByHome(Long homeId);

}