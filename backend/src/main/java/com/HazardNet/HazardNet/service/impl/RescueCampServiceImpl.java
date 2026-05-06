package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.RescueCampDto;
import com.HazardNet.HazardNet.entity.RescueCamp; // Assuming this class exists
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException; // Assuming this class exists
import com.HazardNet.HazardNet.mapper.RescueCampMapper; // Assuming this mapper exists
import com.HazardNet.HazardNet.repository.RescueCampRepository; // Assuming this repository exists
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.RescueCampService;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class RescueCampServiceImpl implements RescueCampService {


    private final RescueCampRepository rescueCampRepository;
    private final RescueCampMapper rescueCampMapper;
    private final UserRepository userRepository;
    private final String UPLOAD_DIR = "uploads/camp/";



    @Override
    @Transactional
    public RescueCampDto createRescueCamp(RescueCampDto dto, MultipartFile imageFile) {


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
                dto.setPeople_image_url(fileName);

            } catch (Exception e) {
                throw new RuntimeException("Could not save image file: " + e.getMessage());
            }
        }

        RescueCamp rescueCamp = rescueCampMapper.toEntity(dto);

        User manager = userRepository.findById(dto.getManagerId())
                .orElseThrow(() -> new NotFoundException(
                        "User not found with ID: " + dto.getManagerId()));

        rescueCamp.setManager(manager);

        RescueCamp savedRescueCamp = rescueCampRepository.save(rescueCamp);

        return rescueCampMapper.toDto(savedRescueCamp);
    }



    @Override
    public List<RescueCampDto> getAllRescueCamps() {

        List<RescueCamp> rescueCamps = rescueCampRepository.findAll();


        return rescueCampMapper.toDtoList(rescueCamps);
    }


    @Override
    public RescueCampDto getRescueCampById(Long id) {

        RescueCamp rescueCamp = rescueCampRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Rescue Camp not found with ID: " + id));


        return rescueCampMapper.toDto(rescueCamp);
    }


    @Override
    @Transactional
    public RescueCampDto updateRescueCamp(Long id, RescueCampDto rescueCampDto, MultipartFile imageFile) {

        RescueCamp existingRescueCamp = rescueCampRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Rescue Camp not found with ID: " + id));

        // Handle the Image Upload
        if (imageFile != null && !imageFile.isEmpty()) {
            try {
                Path uploadPath = Paths.get(UPLOAD_DIR);
                if (!Files.exists(uploadPath)) {
                    Files.createDirectories(uploadPath);
                }

                String fileName = UUID.randomUUID().toString() + "_" + imageFile.getOriginalFilename();
                Path filePath = uploadPath.resolve(fileName);

                Files.copy(imageFile.getInputStream(), filePath);

                // Update the file name in the DTO so the mapper can pick it up
                rescueCampDto.setPeople_image_url(fileName);

            } catch (Exception e) {
                throw new RuntimeException("Could not save image file: " + e.getMessage());
            }
        }


        rescueCampMapper.updateRescueCampFromDto(rescueCampDto, existingRescueCamp);

        if (rescueCampDto.getManagerId() != null) {
            User manager = userRepository.findById(rescueCampDto.getManagerId())
                    .orElseThrow(() -> new NotFoundException(
                            "User not found with ID: " + rescueCampDto.getManagerId()));
            existingRescueCamp.setManager(manager);
        }


        RescueCamp savedRescueCamp = rescueCampRepository.save(existingRescueCamp);


        return rescueCampMapper.toDto(savedRescueCamp);
    }


    @Override
    public Boolean deleteRescueCamp(Long id) {

        if (!rescueCampRepository.existsById(id)) {
            throw new NotFoundException("Rescue Camp not found with ID: " + id);
        }

        rescueCampRepository.deleteById(id);

        return true;
    }
}