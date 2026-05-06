package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.OrphanGroupDto;
import com.HazardNet.HazardNet.entity.OrphanGroup;
import com.HazardNet.HazardNet.entity.RescueCamp;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.OrphanGroupMapper;
import com.HazardNet.HazardNet.repository.OrphanGroupRepository;
import com.HazardNet.HazardNet.repository.RescueCampRepository;
import com.HazardNet.HazardNet.service.OrphanGroupService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrphanGroupServiceImpl implements OrphanGroupService {

    private final OrphanGroupRepository orphanGroupRepository;
    private final OrphanGroupMapper orphanGroupMapper;
    private final RescueCampRepository rescueCampRepository;


    @Override
    public OrphanGroupDto createOrphanGroup(OrphanGroupDto orphanGroupDto) {


        OrphanGroup orphanGroup = orphanGroupMapper.toEntity(orphanGroupDto);


        RescueCamp rescueCamp = rescueCampRepository.findById(orphanGroupDto.getRescueCampId())
                .orElseThrow(() -> new NotFoundException("Rescue Camp not found"));


        orphanGroup.setRescueCamp(rescueCamp);


        OrphanGroup savedOrphanGroup = orphanGroupRepository.save(orphanGroup);


        return orphanGroupMapper.toDto(savedOrphanGroup);
    }


    @Override
    public List<OrphanGroupDto> getAllOrphanGroups() {

        List<OrphanGroup> orphanGroups = orphanGroupRepository.findAll();


        return orphanGroupMapper.toDtoList(orphanGroups);
    }


    @Override
    public OrphanGroupDto getOrphanGroupById(Long id) {

        OrphanGroup orphanGroup = orphanGroupRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Orphan Group not found with ID: " + id));


        return orphanGroupMapper.toDto(orphanGroup);
    }


    @Override
    public OrphanGroupDto updateOrphanGroup(Long id, OrphanGroupDto orphanGroupDto) {

        OrphanGroup existingOrphanGroup = orphanGroupRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Orphan Group not found with ID: " + id));


        orphanGroupMapper.updateOrphanGroupFromDto(orphanGroupDto, existingOrphanGroup);


        OrphanGroup savedOrphanGroup = orphanGroupRepository.save(existingOrphanGroup);


        return orphanGroupMapper.toDto(savedOrphanGroup);
    }


    @Override
    public Boolean deleteOrphanGroup(Long id) {

        if (!orphanGroupRepository.existsById(id)) {
            throw new NotFoundException("Orphan Group not found with ID: " + id);
        }

        orphanGroupRepository.deleteById(id);


        return true;
    }

    // Add this method inside your OrphanGroupServiceImpl class
    @Override
    public List<OrphanGroupDto> getOrphanGroupsByRescueCampId(Long rescueCampId) {

        // 1. Fetch from DB using the new repository method
        List<OrphanGroup> orphanGroups = orphanGroupRepository.findByRescueCamp_Id(rescueCampId);

        // 2. Map the entities to DTOs and return
        return orphanGroupMapper.toDtoList(orphanGroups);
    }
}