package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.HazardAreaDto;
import com.HazardNet.HazardNet.dto.UserDto;
import com.HazardNet.HazardNet.entity.HazardArea; // Assuming this entity exists
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException; // Assuming this exception exists
import com.HazardNet.HazardNet.mapper.HazardAreaMapper;
import com.HazardNet.HazardNet.repository.HazardAreaRepository; // Assuming this repository exists
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.HazardAreaService;
import lombok.RequiredArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class HazardAreaServiceImpl implements HazardAreaService {

    private final HazardAreaRepository hazardAreaRepository;
    private final HazardAreaMapper hazardAreaMapper;
    private final UserRepository userRepository;


    @Override
    public HazardAreaDto createHazardArea(HazardAreaDto hazardAreaDto) {

        HazardArea hazardArea = hazardAreaMapper.toEntity(hazardAreaDto);

        if (hazardAreaDto.getUsers() != null && !hazardAreaDto.getUsers().isEmpty()) {

            List<User> users = hazardAreaDto.getUsers().stream()
                    .map(u -> userRepository.findById(u.getId())
                            .orElseThrow(() -> new NotFoundException("User not found: " + u.getId())))
                    .toList();

            // Set users to hazard area
            hazardArea.setUsers(users);

            // Maintain reverse side properly
            users.forEach(u -> u.getHazardAreas().add(hazardArea));
        }

        HazardArea saved = hazardAreaRepository.save(hazardArea);
        return hazardAreaMapper.toDto(saved);
    }



    @Override
    public List<HazardAreaDto> getAllHazardAreas() {
        return hazardAreaMapper.toDtoList(hazardAreaRepository.findAll());
    }

    @Override
    public HazardAreaDto getHazardAreaById(Long id) {
        HazardArea hazardArea = hazardAreaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Hazard Area not found with ID: " + id));
        return hazardAreaMapper.toDto(hazardArea);
    }

    @Override
    public HazardAreaDto updateHazardArea(Long id, HazardAreaDto hazardAreaDto) {

        HazardArea hazardArea = hazardAreaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("HazardArea not found with ID: " + id));

        hazardAreaMapper.updateHazardAreaFromDto(hazardAreaDto, hazardArea);

        if (hazardAreaDto.getUsers() != null) {

            // clear old relations
            hazardArea.getUsers().forEach(u -> u.getHazardAreas().remove(hazardArea));
            hazardArea.getUsers().clear();

            List<User> users = hazardAreaDto.getUsers().stream()
                    .map(u -> userRepository.findById(u.getId())
                            .orElseThrow(() -> new NotFoundException("User not found: " + u.getId())))
                    .collect(Collectors.toList()); // 🔥 FIX HERE

            hazardArea.setUsers(users);
            users.forEach(u -> u.getHazardAreas().add(hazardArea));
        }

        return hazardAreaMapper.toDto(hazardAreaRepository.save(hazardArea));
    }




    @Override
    @Transactional
    public Boolean deleteHazardArea(Long id) {
        // Find the HazardArea first to handle relations
        HazardArea hazardArea = hazardAreaRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("HazardArea not found with ID: " + id));

        // Clear the relationship from the owning side (User)
        // Since User owns the relationship, we must remove it from each user's list
        if (hazardArea.getUsers() != null) {
            hazardArea.getUsers().forEach(user -> user.getHazardAreas().remove(hazardArea));
            hazardArea.getUsers().clear();
        }

        // Now we can safely delete the HazardArea
        hazardAreaRepository.delete(hazardArea);
        return true;
    }
}