package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.HomeDto;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

public interface HomeService {

    HomeDto createHome(HomeDto homeDto, MultipartFile imageFile);
    List<HomeDto> getAllHomes();
    HomeDto getHomeById(Long id);

    HomeDto updateHome(Long id, HomeDto homeDto);

    Boolean deleteHome(Long id);

    List<HomeDto> getHomesByUserId(Long userId);

}