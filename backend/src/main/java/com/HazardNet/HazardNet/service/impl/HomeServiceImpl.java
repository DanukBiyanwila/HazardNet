package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.HomeDto;
import com.HazardNet.HazardNet.entity.Home;
import com.HazardNet.HazardNet.entity.HomeRiskStatus;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.HomeMapper;
import com.HazardNet.HazardNet.repository.HomeRepository;
import com.HazardNet.HazardNet.repository.HomeRiskStatusRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.HomeService;

import java.util.ArrayList;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class HomeServiceImpl implements HomeService {

    private final HomeRepository homeRepository;
    private final HomeMapper homeMapper;
    private  final HomeRiskStatusRepository homeRiskStatusRepository;
    private final UserRepository userRepository;
    private final String UPLOAD_DIR = "uploads/homes/";

    @Override
    @Transactional
    public HomeDto createHome(HomeDto homeDto, MultipartFile imageFile) {

        // 1. Handle the Image Upload First
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                // Create the directory if it doesn't exist
                Path uploadPath = Paths.get(UPLOAD_DIR);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }

                // Generate a unique file name so images don't overwrite each other
                String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
                Path filePath = uploadPath.resolve(fileName);

                // Save the file to the folder
                Files.copy(imageFile.getInputStream(), filePath);

                // Set the path/url in the DTO
                homeDto.setImageUrl(fileName);

            } catch (Exception e) {
                throw new RuntimeException("Could not save image file: " + e.getMessage());
            }
        }

        Home home = homeMapper.toEntity(homeDto);


        if (homeDto.getUserIds() != null && !homeDto.getUserIds().isEmpty()) {
            List<User> users = userRepository.findAllById(homeDto.getUserIds());
            home.setUsers(users);
        }


        if (homeDto.getHomeRiskStatusIds() != null && !homeDto.getHomeRiskStatusIds().isEmpty()) {
            List<HomeRiskStatus> risks = homeRiskStatusRepository.findAllById(homeDto.getHomeRiskStatusIds());
            risks.forEach(risk -> risk.setHome(home));
            home.setRiskStatuses(risks);
        }

        Home savedHome = homeRepository.save(home);

        HomeDto dto = homeMapper.toDto(savedHome);

        // Set userIds manually
        if (savedHome.getUsers() != null) {
            dto.setUserIds(savedHome.getUsers().stream().map(User::getId).toList());
        }

        // Set riskStatusIds manually
        if (savedHome.getRiskStatuses() != null) {
            dto.setHomeRiskStatusIds(savedHome.getRiskStatuses().stream().map(HomeRiskStatus::getId).toList());
        }

        return dto;
    }


    @Override
    public List<HomeDto> getAllHomes() {

        List<Home> homes = homeRepository.findAll();

        return homes.stream().map(home -> {

            HomeDto dto = homeMapper.toDto(home);

            dto.setUserIds(home.getUsers().stream().map(User::getId).toList());
            dto.setHomeRiskStatusIds(home.getRiskStatuses().stream().map(HomeRiskStatus::getId).toList());

            return dto;
        }).toList();
    }

    @Override
    public HomeDto getHomeById(Long id) {

        Home home = homeRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Home not found with ID: " + id));

        HomeDto dto = homeMapper.toDto(home);

        dto.setUserIds(home.getUsers().stream().map(User::getId).toList());
        dto.setHomeRiskStatusIds(home.getRiskStatuses().stream().map(HomeRiskStatus::getId).toList());

        return dto;
    }



    @Override
    public HomeDto updateHome(Long id, HomeDto homeDto) {

        Home existingHome = homeRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Home not found with ID: " + id));


        homeMapper.updateHomeFromDto(homeDto, existingHome);


        Home savedHome = homeRepository.save(existingHome);


        return homeMapper.toDto(savedHome);
    }


    @Override
    public Boolean deleteHome(Long id) {

        if (!homeRepository.existsById(id)) {
            throw new NotFoundException("Home not found with ID: " + id);
        }

        homeRepository.deleteById(id);

        return true;
    }

    @Override
    public List<HomeDto> getHomesByUserId(Long userId) {

        // Use the new repository method to get only homes for this user
        List<Home> homes = homeRepository.findByUsers_Id(userId);

        // Map the entities to DTOs just like you did in getAllHomes()
        return homes.stream().map(home -> {

            HomeDto dto = homeMapper.toDto(home);

            // Set userIds manually
            if (home.getUsers() != null) {
                dto.setUserIds(home.getUsers().stream().map(User::getId).toList());
            }

            // Set riskStatusIds manually
            if (home.getRiskStatuses() != null) {
                dto.setHomeRiskStatusIds(home.getRiskStatuses().stream().map(HomeRiskStatus::getId).toList());
            }

            return dto;
        }).toList();
    }
}