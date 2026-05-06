package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.*;
import com.HazardNet.HazardNet.entity.HazardArea;
import com.HazardNet.HazardNet.entity.Home;
import com.HazardNet.HazardNet.entity.Role;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.BadRequestException;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.exception.UnauthorizedException;
import com.HazardNet.HazardNet.mapper.UserMapper;
import com.HazardNet.HazardNet.repository.HazardAreaRepository;
import com.HazardNet.HazardNet.repository.HomeRepository;
import com.HazardNet.HazardNet.repository.RoleRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.security.JwtService;
import com.HazardNet.HazardNet.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;

    private final HazardAreaRepository hazardAreaRepository;

    private final RoleRepository roleRepository;

    private  final HomeRepository homeRepository;

    private final UserMapper userMapper;

    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    private final String UPLOAD_DIR = "uploads/users/";



    @Override
    @Transactional
    public UserDto createUser(UserDto userDto, MultipartFile imageFile) {

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
                userDto.setImageUrl(fileName);

            } catch (Exception e) {
                throw new RuntimeException("Could not save user image file: " + e.getMessage());
            }
        }


        User user = userMapper.toEntity(userDto);
        // Explicitly set the image URL in case the mapper missed it
        user.setImageUrl(userDto.getImageUrl());

        //already in email check
        if (userRepository.existsByEmail(userDto.getEmail())) {
            throw new BadRequestException("Email already in use");
        }

        if (userDto.getHazardAreaDtos() != null && !userDto.getHazardAreaDtos().isEmpty()) {


            List<Long> hazardIds = userDto.getHazardAreaDtos().stream()
                    .map(HazardAreaDto::getId)
                    .toList();

            List<HazardArea> hazardAreas = hazardIds.stream()
                    .map(id -> hazardAreaRepository.findById(id)
                            .orElseThrow(() -> new NotFoundException("Hazard Area not found: " + id)))
                    .toList();


            user.setHazardAreas(hazardAreas);


            hazardAreas.forEach(h -> h.getUsers().add(user));
        }

        // Homes
        if (userDto.getHomeIds() != null && !userDto.getHomeIds().isEmpty()) {

            List<Home> homes = userDto.getHomeIds().stream()
                    .map(id -> homeRepository.findById(id)
                            .orElseThrow(() -> new NotFoundException("Home not found: " + id)))
                    .toList();

            user.setHomes(homes);


            homes.forEach(h -> h.getUsers().add(user));
        }


        if(userDto.getRole() != null && userDto.getRole().getId() != null) {
            Role role = roleRepository.findById(userDto.getRole().getId())
                    .orElseThrow(() -> new NotFoundException("Role not found"));
            user.setRole(role);
        }

        //password encrpt
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // Save final user
        User savedUser = userRepository.save(user);


        UserDto response = userMapper.toDto(savedUser);
        response.setHomeIds(
                savedUser.getHomes().stream().map(Home::getId).toList()
        );

        return response;
    }


    @Override
    public List<UserDto> getAllUsers() {
        return userMapper.toDtoList(userRepository.findAll());
    }

    @Override
    public UserDto getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found with ID: " + id));
        return userMapper.toDto(user);
    }

    @Override
    public UserDto updateUser(Long id, UserDto userDto) {
        User existingUser = userRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("User not found with ID: " + id));


        if (userDto.getEmail() != null &&
                !userDto.getEmail().equals(existingUser.getEmail())) {

            if (userRepository.existsByEmailAndIdNot(userDto.getEmail(), id)) {
                throw new BadRequestException("Email already in use");
            }


            existingUser.setEmail(userDto.getEmail());
        }

        userMapper.updateUserFromDto(userDto, existingUser);

        User savedUser = userRepository.save(existingUser);

        return userMapper.toDto(savedUser);
    }

    @Override
    public Boolean deleteUser(Long id) {
        userRepository.deleteById(id);
        return true;
    }

    @Override
    public AuthResponseDto loginUser(LoginRequestDto loginRequestDto) {
        // 1. Find user by email
        User user = userRepository.findByEmail(loginRequestDto.getEmail())
                .orElseThrow(() -> new UnauthorizedException("Invalid email or password"));

        // 2. Check Password using BCrypt
        if (!passwordEncoder.matches(loginRequestDto.getPassword(), user.getPassword())) {
            throw new UnauthorizedException("Invalid email or password");
        }

        // 3. Generate REAL Token
        String token = jwtService.generateToken(user.getEmail());

        // 4. Map User
        UserSimpleDetailsDto userDetails = new UserSimpleDetailsDto();
        userDetails.setId(user.getId());
        userDetails.setName(user.getName());
        userDetails.setEmail(user.getEmail());
        userDetails.setRole(userMapper.map(user.getRole()));

        // 5. Return Response
        return new AuthResponseDto(token, userDetails);
    }
}
