package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.HazardPredictionDto; // Assuming this DTO exists
import com.HazardNet.HazardNet.entity.HazardPrediction; // Assuming this Entity exists
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring")
public interface HazardPredictionmapper {

    HazardPredictionDto toDto(HazardPrediction hazardPrediction);

    HazardPrediction toEntity(HazardPredictionDto hazardPredictionDto);


    List<HazardPredictionDto> toDtoList(List<HazardPrediction> hazardPredictions);


    void updateHazardPredictionFromDto(HazardPredictionDto dto, @MappingTarget HazardPrediction entity);

    List<HazardPrediction> toEntityList(List<HazardPredictionDto> dtos);

}