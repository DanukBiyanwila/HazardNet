package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.LocationResponseDTO;
import com.HazardNet.HazardNet.service.LocationService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class LocationServiceImpl implements LocationService {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private static final String API_KEY = "AIzaSyCs1dEUOfpICKD4prF89cSZs1tjOceC190";

    @Override
    public LocationResponseDTO getLocationDetails(double lat, double lng) {
        String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="
                + lat + "," + lng + "&key=" + API_KEY;

        try {
            System.out.println("Fetching location from Google API: " + url);
            String response = restTemplate.getForObject(url, String.class);
            System.out.println("Google API Response: " + response);
            
            JsonNode root = objectMapper.readTree(response);
            String status = root.path("status").asText();

            if ("OK".equals(status)) {
                JsonNode results = root.path("results");
                if (results.isArray() && results.size() > 0) {
                    JsonNode firstResult = results.get(0);
                    JsonNode addressComponents = firstResult.path("address_components");

                    String city = "Unknown";
                    String district = "Unknown";
                    String country = "Unknown";

                    for (JsonNode component : addressComponents) {
                        JsonNode types = component.path("types");
                        for (JsonNode typeNode : types) {
                            String type = typeNode.asText();
                            
                            // For Sri Lanka:
                            // locality or sublocality_level_1 usually gives the town/city
                            if ("locality".equals(type) || "sublocality_level_1".equals(type)) {
                                city = component.path("long_name").asText();
                            }
                            // administrative_area_level_2 is often the District
                            if ("administrative_area_level_2".equals(type)) {
                                district = component.path("long_name").asText();
                            }
                            // country is the Country
                            if ("country".equals(type)) {
                                country = component.path("long_name").asText();
                            }
                        }
                    }
                    
                    // Fallback: If city is still unknown, try administrative_area_level_3
                    if ("Unknown".equals(city)) {
                        for (JsonNode component : addressComponents) {
                            if (component.path("types").toString().contains("administrative_area_level_3")) {
                                city = component.path("long_name").asText();
                            }
                        }
                    }

                    return new LocationResponseDTO(city, district, country);
                }
            } else {
                System.err.println("Google API Error Status: " + status);
                if (root.has("error_message")) {
                    System.err.println("Error Message: " + root.get("error_message").asText());
                }
            }
        } catch (Exception e) {
            System.err.println("Exception while calling Google API: " + e.getMessage());
            e.printStackTrace();
        }

        return new LocationResponseDTO("Unknown", "Unknown", "Unknown");
    }
}
