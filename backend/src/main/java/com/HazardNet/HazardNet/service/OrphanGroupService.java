package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.OrphanGroupDto;
import java.util.List;

public interface OrphanGroupService {

    OrphanGroupDto createOrphanGroup(OrphanGroupDto orphanGroupDto);

    List<OrphanGroupDto> getAllOrphanGroups();

    OrphanGroupDto getOrphanGroupById(Long id);

    OrphanGroupDto updateOrphanGroup(Long id, OrphanGroupDto orphanGroupDto);

    Boolean deleteOrphanGroup(Long id);

    List<OrphanGroupDto> getOrphanGroupsByRescueCampId(Long rescueCampId);

}