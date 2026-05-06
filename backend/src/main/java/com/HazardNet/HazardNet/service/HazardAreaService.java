package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.HazardAreaDto;

import java.util.List;

public interface HazardAreaService {

    HazardAreaDto createHazardArea(HazardAreaDto HazardAreaDto);

    List<HazardAreaDto> getAllHazardAreas();

    HazardAreaDto getHazardAreaById(Long id);

    HazardAreaDto updateHazardArea(Long id, HazardAreaDto HazardAreaDto);

    Boolean deleteHazardArea(Long id);

}
