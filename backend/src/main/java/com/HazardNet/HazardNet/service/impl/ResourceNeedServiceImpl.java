package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.ResourceNeedDto;
import com.HazardNet.HazardNet.entity.RescueCamp;
import com.HazardNet.HazardNet.entity.ResourceNeed;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.ResourceNeedMapper;
import com.HazardNet.HazardNet.repository.RescueCampRepository;
import com.HazardNet.HazardNet.repository.ResourceNeedRepository;
import com.HazardNet.HazardNet.service.ResourceNeedService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ResourceNeedServiceImpl implements ResourceNeedService {

    private final ResourceNeedRepository resourceNeedRepository;
    private final ResourceNeedMapper resourceNeedMapper;

    private final RescueCampRepository rescueCampRepository;


    @Override
    public ResourceNeedDto createResourceNeed(ResourceNeedDto resourceNeedDto) {

        ResourceNeed resourceNeed = resourceNeedMapper.toEntity(resourceNeedDto);

        if (resourceNeedDto.getRescueCampId() != null) {
            RescueCamp rescueCamp = rescueCampRepository.findById(resourceNeedDto.getRescueCampId())
                    .orElseThrow(() -> new RuntimeException("Rescue camp not found!"));

            resourceNeed.setRescueCamp(rescueCamp);
        }


        ResourceNeed savedResourceNeed = resourceNeedRepository.save(resourceNeed);


        return resourceNeedMapper.toDto(savedResourceNeed);
    }


    @Override
    public List<ResourceNeedDto> getAllResourceNeeds() {

        List<ResourceNeed> resourceNeeds = resourceNeedRepository.findAll();


        return resourceNeedMapper.toDtoList(resourceNeeds);
    }


    @Override
    public ResourceNeedDto getResourceNeedById(Long id) {

        ResourceNeed resourceNeed = resourceNeedRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Resource Need not found with ID: " + id));


        return resourceNeedMapper.toDto(resourceNeed);
    }


    @Override
    public ResourceNeedDto updateResourceNeed(Long id, ResourceNeedDto resourceNeedDto) {

        ResourceNeed existingResourceNeed = resourceNeedRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Resource Need not found with ID: " + id));


        resourceNeedMapper.updateResourceNeedFromDto(resourceNeedDto, existingResourceNeed);


        ResourceNeed savedResourceNeed = resourceNeedRepository.save(existingResourceNeed);


        return resourceNeedMapper.toDto(savedResourceNeed);
    }


    @Override
    public Boolean deleteResourceNeed(Long id) {

        if (!resourceNeedRepository.existsById(id)) {
            throw new NotFoundException("Resource Need not found with ID: " + id);
        }

        resourceNeedRepository.deleteById(id);


        return true;
    }
}