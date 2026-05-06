package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.MediaVerificationDto;

import java.util.List;

public interface MediaVerificationService {

    MediaVerificationDto createMediaVerification(MediaVerificationDto mediaVerificationDto);
    List<MediaVerificationDto> getAllMediaVerifications();
    MediaVerificationDto getMediaVerificationById(Long id);

    MediaVerificationDto updateMediaVerification(Long id, MediaVerificationDto mediaVerificationDto);

    Boolean deleteMediaVerification(Long id);

}