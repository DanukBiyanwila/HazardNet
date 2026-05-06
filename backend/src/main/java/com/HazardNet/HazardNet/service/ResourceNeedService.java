package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.ResourceNeedDto;
import java.util.List;

public interface ResourceNeedService {

    ResourceNeedDto createResourceNeed(ResourceNeedDto resourceNeedDto);

    List<ResourceNeedDto> getAllResourceNeeds();

    ResourceNeedDto getResourceNeedById(Long id);

    ResourceNeedDto updateResourceNeed(Long id, ResourceNeedDto resourceNeedDto);

    Boolean deleteResourceNeed(Long id);

}