package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.MediaVerificationDto;
import com.HazardNet.HazardNet.entity.MediaReport;
import com.HazardNet.HazardNet.entity.MediaVerification;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.MediaVerificationMapper;
import com.HazardNet.HazardNet.repository.MediaReportRepository;
import com.HazardNet.HazardNet.repository.MediaVerificationRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.MediaVerificationService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MediaVerificationServiceImpl implements MediaVerificationService {

    private final MediaVerificationRepository mediaVerificationRepository;
    private final MediaVerificationMapper mediaVerificationMapper;
    private final UserRepository userRepository;
    private final MediaReportRepository mediaReportRepository;


    @Override
    public MediaVerificationDto createMediaVerification(MediaVerificationDto dto) {

        MediaVerification verification =
                mediaVerificationMapper.toEntity(dto);

        User user = userRepository.findById(dto.getUserId())
                .orElseThrow(() -> new NotFoundException("User not found"));

        MediaReport report = mediaReportRepository.findById(dto.getMediaReportId())
                .orElseThrow(() -> new NotFoundException("Media Report not found"));

        // SET RELATIONS
        verification.setUser(user);
        verification.setMediaReport(report);
        report.setMediaVerification(verification);

        MediaVerification saved =
                mediaVerificationRepository.save(verification);

        MediaVerificationDto response =
                mediaVerificationMapper.toDto(saved);

        response.setUserId(user.getId());
        response.setMediaReportId(report.getId());

        return response;
    }


    @Override
    public List<MediaVerificationDto> getAllMediaVerifications() {

        return mediaVerificationRepository.findAll().stream().map(v -> {

            MediaVerificationDto dto =
                    mediaVerificationMapper.toDto(v);

            dto.setUserId(v.getUser().getId());
            return dto;

        }).toList();
    }


    @Override
    public MediaVerificationDto getMediaVerificationById(Long id) {

        MediaVerification mediaVerification =
                mediaVerificationRepository.findById(id)
                        .orElseThrow(() ->
                                new NotFoundException("Media Verification not found"));

        MediaVerificationDto dto =
                mediaVerificationMapper.toDto(mediaVerification);

        dto.setUserId(mediaVerification.getUser().getId());

        return dto;
    }


    @Override
    public MediaVerificationDto updateMediaVerification(Long id, MediaVerificationDto mediaVerificationDto) {

        MediaVerification existingMediaVerification = mediaVerificationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Media Verification not found with ID: " + id));


        mediaVerificationMapper.updateMediaVerificationFromDto(mediaVerificationDto, existingMediaVerification);


        MediaVerification savedMediaVerification = mediaVerificationRepository.save(existingMediaVerification);


        return mediaVerificationMapper.toDto(savedMediaVerification);
    }


    @Override
    public Boolean deleteMediaVerification(Long id) {

        if (!mediaVerificationRepository.existsById(id)) {
            throw new NotFoundException("Media Verification not found with ID: " + id);
        }

        mediaVerificationRepository.deleteById(id);

        return true;
    }
}