package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.MediaReportDto;
import com.HazardNet.HazardNet.entity.MediaReport;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.BadRequestException;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.MediaReportMapper;
import com.HazardNet.HazardNet.repository.MediaReportRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.MediaReportService;

import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MediaReportServiceImpl implements MediaReportService {

    private final MediaReportRepository mediaReportRepository;
    private final MediaReportMapper mediaReportMapper;
    private final UserRepository userRepository;
    private final String UPLOAD_DIR = "uploads/reports/";

    @Override
    @Transactional
    public MediaReportDto createMediaReport(MediaReportDto mediaReportDto, MultipartFile file) {
        try {
            // 1. Handle the File Upload
            if (file != null && !file.isEmpty()) {
                try {
                    Path uploadPath = Paths.get(UPLOAD_DIR);
                    if (!Files.exists(uploadPath)) {
                        Files.createDirectories(uploadPath);
                    }

                    String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
                    Path filePath = uploadPath.resolve(fileName);
                    Files.copy(file.getInputStream(), filePath);

                    mediaReportDto.setMedia_url(fileName);
                } catch (Exception e) {
                    throw new RuntimeException("Could not save media file: " + e.getMessage());
                }
            }

            // Set upload time if missing
            if (mediaReportDto.getUpload_time() == null) {
                mediaReportDto.setUpload_time(LocalDateTime.now());
            }

            MediaReport mediaReport = mediaReportMapper.toEntity(mediaReportDto);
            // Explicitly set media_url to ensure it is saved
            mediaReport.setMedia_url(mediaReportDto.getMedia_url());

            User user = userRepository.findById(mediaReportDto.getUserId())
                    .orElseThrow(() -> new NotFoundException("User not found"));

            mediaReport.setUser(user);
            user.getMediaReports().add(mediaReport);

            MediaReport saved = mediaReportRepository.save(mediaReport);

            MediaReportDto response = mediaReportMapper.toDto(saved);
            response.setUserId(user.getId());

            return response;

        } catch (DataIntegrityViolationException ex) {
            throw new BadRequestException("Media verification already exists for this report");
        }
    }


    @Override
    public List<MediaReportDto> getAllMediaReports() {
        return mediaReportRepository.findAll().stream().map(report -> {

            MediaReportDto dto = mediaReportMapper.toDto(report);
            dto.setUserId(report.getUser().getId());
            return dto;

        }).toList();
    }


    @Override
    public MediaReportDto getMediaReportById(Long id) {
        MediaReport mediaReport = mediaReportRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Media Report not found"));

        return mediaReportMapper.toDto(mediaReport);
    }



    @Override
    public MediaReportDto updateMediaReport(Long id, MediaReportDto mediaReportDto) {

        MediaReport existingMediaReport = mediaReportRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Media Report not found with ID: " + id));


        mediaReportMapper.updateMediaReportFromDto(mediaReportDto, existingMediaReport);


        MediaReport savedMediaReport = mediaReportRepository.save(existingMediaReport);


        return mediaReportMapper.toDto(savedMediaReport);
    }


    @Override
    public Boolean deleteMediaReport(Long id) {

        if (!mediaReportRepository.existsById(id)) {
            throw new NotFoundException("Media Report not found with ID: " + id);
        }

        mediaReportRepository.deleteById(id);

        return true;
    }
}