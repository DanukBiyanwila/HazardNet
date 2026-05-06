package com.HazardNet.HazardNet.service;

import org.springframework.web.multipart.MultipartFile;

public interface VisionService {
    Integer countPeople(MultipartFile image);
}
