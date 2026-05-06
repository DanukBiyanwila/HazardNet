package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.RescueCampDto;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface RescueCampService {

    RescueCampDto createRescueCamp(RescueCampDto rescueCampDto, MultipartFile imageFile);

    List<RescueCampDto> getAllRescueCamps();

    RescueCampDto getRescueCampById(Long id);

    RescueCampDto updateRescueCamp(Long id, RescueCampDto rescueCampDto, MultipartFile imageFile);

    Boolean deleteRescueCamp(Long id);

}