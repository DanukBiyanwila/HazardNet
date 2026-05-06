package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.MediaReportDto;
import com.HazardNet.HazardNet.entity.MediaReport;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface MediaReportMapper {

    @Mapping(target = "userId", source = "user.id")
    @Mapping(target = "media_url", source = "media_url")
    @Mapping(
            target = "mediaVerificationId",
            expression = "java(mediaReport.getMediaVerification() != null ? mediaReport.getMediaVerification().getId() : null)"
    )
    MediaReportDto toDto(MediaReport mediaReport);

    @Mapping(target = "user", ignore = true)
    @Mapping(target = "mediaVerification", ignore = true)
    @Mapping(target = "media_url", source = "media_url")
    MediaReport toEntity(MediaReportDto mediaReportDto);

    List<MediaReportDto> toDtoList(List<MediaReport> mediaReports);

    void updateMediaReportFromDto(MediaReportDto dto, @MappingTarget MediaReport entity);
}
