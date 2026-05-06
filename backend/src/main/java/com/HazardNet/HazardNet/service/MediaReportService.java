package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.MediaReportDto;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface MediaReportService {

    MediaReportDto createMediaReport(MediaReportDto mediaReportDto, MultipartFile file);
    List<MediaReportDto> getAllMediaReports();
    MediaReportDto getMediaReportById(Long id);

    MediaReportDto updateMediaReport(Long id, MediaReportDto mediaReportDto);

    Boolean deleteMediaReport(Long id);

}