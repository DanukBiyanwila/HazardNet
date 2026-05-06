package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.HazardPredictionDto;

import java.util.List;

public interface HazardPredictionService {

    HazardPredictionDto createHazardPrediction(HazardPredictionDto hazardPredictionDto);
    List<HazardPredictionDto> getAllHazardPredictions();
    HazardPredictionDto getHazardPredictionById(Long id);

    HazardPredictionDto updateHazardPrediction(Long id, HazardPredictionDto hazardPredictionDto);

    Boolean deleteHazardPrediction(Long id);

    HazardPredictionDto createHazardPrediction_using_prediction_flood(HazardPredictionDto hazardPredictionDto);

    HazardPredictionDto createHazardPrediction_using_prediction_landslide(HazardPredictionDto hazardPredictionDto);

}