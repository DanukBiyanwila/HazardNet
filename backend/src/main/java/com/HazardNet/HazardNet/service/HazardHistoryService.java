package com.HazardNet.HazardNet.service;
import com.HazardNet.HazardNet.dto.HazardHistoryDto;

import java.util.List;

public interface HazardHistoryService {


    HazardHistoryDto createHazardHistory(HazardHistoryDto hazardHistoryDto);


    List<HazardHistoryDto> getAllHazardHistories();

    HazardHistoryDto getHazardHistoryById(Long id);


    HazardHistoryDto updateHazardHistory(Long id, HazardHistoryDto hazardHistoryDto);

    Boolean deleteHazardHistory(Long id);

}