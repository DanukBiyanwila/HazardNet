package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.AuthResponseDto;
import com.HazardNet.HazardNet.dto.LoginRequestDto;
import com.HazardNet.HazardNet.dto.UserDto;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface UserService {
    UserDto createUser(UserDto userDto, MultipartFile imageFile);

    List<UserDto> getAllUsers();

    UserDto getUserById(Long id);

    UserDto updateUser(Long id, UserDto userDto);

    Boolean deleteUser(Long id);

    // Add to interface
    AuthResponseDto loginUser(LoginRequestDto loginRequestDto);

}
