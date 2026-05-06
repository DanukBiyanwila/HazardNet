package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.HazardPredictionDto;
import com.HazardNet.HazardNet.dto.LocationResponseDTO;
import com.HazardNet.HazardNet.entity.HazardArea;
import com.HazardNet.HazardNet.entity.HazardPrediction;
import com.HazardNet.HazardNet.exception.BadRequestException;
import com.HazardNet.HazardNet.exception.NotFoundException; // Assuming this class exists
import com.HazardNet.HazardNet.mapper.HazardPredictionmapper; // Note the name 'HazardPredictionmapper'
import com.HazardNet.HazardNet.repository.HazardAreaRepository;
import com.HazardNet.HazardNet.repository.HazardPredictionRepository; // Assuming this repository exists
import com.HazardNet.HazardNet.service.HazardPredictionService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.HazardNet.HazardNet.service.LocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class HazardPredictionServiceImpl implements HazardPredictionService {

    // Dependencies: Repository and Mapper
    private final HazardPredictionRepository hazardPredictionRepository;
    private final HazardPredictionmapper hazardPredictionmapper;
    private final HazardAreaRepository hazardAreaRepository;
    private final RestTemplate restTemplate;

    private final LocationService locationService;


    @Override
    public HazardPredictionDto createHazardPrediction(HazardPredictionDto hazardPredictionDto) {


        HazardPrediction hazardPrediction = hazardPredictionmapper.toEntity(hazardPredictionDto);

        HazardPrediction saved = hazardPredictionRepository.save(hazardPrediction);


        return hazardPredictionmapper.toDto(saved);
    }



    @Override
    public List<HazardPredictionDto> getAllHazardPredictions() {

        List<HazardPrediction> hazardPredictions = hazardPredictionRepository.findAll();


        return hazardPredictionmapper.toDtoList(hazardPredictions);
    }


    @Override
    public HazardPredictionDto getHazardPredictionById(Long id) {

        HazardPrediction hazardPrediction = hazardPredictionRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Hazard Prediction not found with ID: " + id));


        return hazardPredictionmapper.toDto(hazardPrediction);
    }


    @Override
    public HazardPredictionDto updateHazardPrediction(Long id, HazardPredictionDto hazardPredictionDto) {

        HazardPrediction existingHazardPrediction = hazardPredictionRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Hazard Prediction not found with ID: " + id));


        hazardPredictionmapper.updateHazardPredictionFromDto(hazardPredictionDto, existingHazardPrediction);


        HazardPrediction savedHazardPrediction = hazardPredictionRepository.save(existingHazardPrediction);


        return hazardPredictionmapper.toDto(savedHazardPrediction);
    }


    @Override
    public Boolean deleteHazardPrediction(Long id) {

        if (!hazardPredictionRepository.existsById(id)) {
            throw new NotFoundException("Hazard Prediction not found with ID: " + id);
        }


        hazardPredictionRepository.deleteById(id);


        return true;
    }

    @Override
    public HazardPredictionDto createHazardPrediction_using_prediction_flood(HazardPredictionDto hazardPredictionDto) {

        //  Prepare Data for Python API
        String pythonUrl = "http://localhost:8080/predict/flood";

        Map<String, Object> pythonRequest = new HashMap<>();

        pythonRequest.put("rainfall_7d_mm", Double.parseDouble(hazardPredictionDto.getRainfall_mm()));
        pythonRequest.put("river_level", Double.parseDouble(hazardPredictionDto.getRiver_level()));
        pythonRequest.put("soil_moisture", Double.parseDouble(hazardPredictionDto.getSoil_moisture()));

        //  Call Python API
        ResponseEntity<Map> response = restTemplate.postForEntity(pythonUrl, pythonRequest, Map.class);
        Map<String, Object> body = response.getBody();

        //  Set prediction values from Python response back to DTO
        if (body != null) {
            hazardPredictionDto.setPredicted_type((String) body.get("predicted_type"));
            hazardPredictionDto.setPredicted_risk_level((String) body.get("predicted_risk_level"));
            hazardPredictionDto.setConfidence_score(body.get("confidence_score").toString());
        }

        //  Map DTO to Entity
        HazardPrediction hazardPrediction = hazardPredictionmapper.toEntity(hazardPredictionDto);

        if (hazardPrediction.getCreated_at() == null) {
            hazardPrediction.setCreated_at(java.time.LocalDateTime.now().toString());
        }

        //  Save to HazardPrediction DB
        HazardPrediction saved = hazardPredictionRepository.save(hazardPrediction);


        // NEW: GET LOCATION & SAVE TO HAZARD AREA (Only if risk is NOT LOW)
        if (!"LOW".equalsIgnoreCase(hazardPredictionDto.getPredicted_risk_level())) {
            // Get City, District, Country from Google API
            LocationResponseDTO location = locationService.getLocationDetails(
                    hazardPredictionDto.getLocation_lat(),
                    hazardPredictionDto.getLocation_lon()
            );

            // Check if the location is valid. If it returns "Unknown", the coordinates are likely wrong.
            if ("Unknown".equals(location.getCity()) || "Unknown".equals(location.getCountry())) {
                throw new BadRequestException("Invalid location coordinates. Please provide valid latitude and longitude.");
            }

            // Create a new HazardArea entity
            HazardArea hazardArea = new HazardArea();

            // Set dynamic name based on prediction (e.g., "FLOOD Risk Zone")
            hazardArea.setName(hazardPredictionDto.getPredicted_type() + " Risk Zone");

            hazardArea.setLocation_lat(hazardPredictionDto.getLocation_lat());
            hazardArea.setLocation_lon(hazardPredictionDto.getLocation_lon());
            hazardArea.setCity(location.getCity());
            hazardArea.setDistrict(location.getDistrict());
            hazardArea.setSeverity_level(hazardPredictionDto.getPredicted_risk_level());
            hazardArea.setRadius_meters("1500"); // Default radius, you can change this
            hazardArea.setCreated_at(new java.util.Date()); // Use java.util.Date for HazardArea

            // Save to HazardArea DB
            hazardAreaRepository.save(hazardArea);
            System.out.println("Successfully saved new Hazard Area for: " + location.getCity());
        }

        //  Return the saved data
        return hazardPredictionmapper.toDto(saved);
    }

    @Override
    public HazardPredictionDto createHazardPrediction_using_prediction_landslide(HazardPredictionDto hazardPredictionDto) {

        // Prepare Data for Python API - Pointing to LANDSLIDE endpoint
        String pythonUrl = "http://localhost:8080/predict/landslide";

        Map<String, Object> pythonRequest = new HashMap<>();

        // Parse Strings to Doubles so Python doesn't throw a Math/TypeError
        pythonRequest.put("rainfall_7d_mm", Double.parseDouble(hazardPredictionDto.getRainfall_mm()));
        pythonRequest.put("river_level", Double.parseDouble(hazardPredictionDto.getRiver_level()));
        pythonRequest.put("soil_moisture", Double.parseDouble(hazardPredictionDto.getSoil_moisture()));

        // Call Python API
        ResponseEntity<Map> response = restTemplate.postForEntity(pythonUrl, pythonRequest, Map.class);
        Map<String, Object> body = response.getBody();

        // Set prediction values from Python response back to DTO
        if (body != null) {
            hazardPredictionDto.setPredicted_type((String) body.get("predicted_type")); // Python should return "LANDSLIDE"
            hazardPredictionDto.setPredicted_risk_level((String) body.get("predicted_risk_level"));
            hazardPredictionDto.setConfidence_score(body.get("confidence_score").toString());
        }

        // Map DTO to Entity
        HazardPrediction hazardPrediction = hazardPredictionmapper.toEntity(hazardPredictionDto);


        // Optional: Automatically set created_at if it's empty
        if (hazardPrediction.getCreated_at() == null) {
            hazardPrediction.setCreated_at(java.time.LocalDateTime.now().toString());
        }

        // Save to DB
        HazardPrediction saved = hazardPredictionRepository.save(hazardPrediction);


        // NEW: GET LOCATION & SAVE TO HAZARD AREA FOR LANDSLIDE (Only if risk is NOT LOW)
        if (!"LOW".equalsIgnoreCase(hazardPredictionDto.getPredicted_risk_level())) {
            // Get City, District, Country from Google API
            LocationResponseDTO location = locationService.getLocationDetails(
                    hazardPredictionDto.getLocation_lat(),
                    hazardPredictionDto.getLocation_lon()
            );

            // Check if the location is valid. If it returns "Unknown", the coordinates are likely wrong.
            if ("Unknown".equals(location.getCity()) || "Unknown".equals(location.getCountry())) {
                throw new BadRequestException("Invalid location coordinates. Please provide valid latitude and longitude.");
            }

            // Create a new HazardArea entity
            HazardArea hazardArea = new HazardArea();

            // Set dynamic name based on prediction (e.g., "LANDSLIDE Risk Zone")
            hazardArea.setName(hazardPredictionDto.getPredicted_type() + " Risk Zone");

            hazardArea.setLocation_lat(hazardPredictionDto.getLocation_lat());
            hazardArea.setLocation_lon(hazardPredictionDto.getLocation_lon());
            hazardArea.setCity(location.getCity());
            hazardArea.setDistrict(location.getDistrict());
            hazardArea.setSeverity_level(hazardPredictionDto.getPredicted_risk_level());
            hazardArea.setRadius_meters("1500"); // Default radius, you can change this
            hazardArea.setCreated_at(new java.util.Date()); // Use java.util.Date for HazardArea

            // Save to HazardArea DB
            hazardAreaRepository.save(hazardArea);
            System.out.println("Successfully saved new Hazard Area for Landslide in: " + location.getCity());
        }


        // Return the saved data
        return hazardPredictionmapper.toDto(saved);
    }
}