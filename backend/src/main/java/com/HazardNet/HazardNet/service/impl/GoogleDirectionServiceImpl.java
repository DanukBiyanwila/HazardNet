package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.service.GoogleDirectionService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class GoogleDirectionServiceImpl implements GoogleDirectionService {

    private final String API_KEY = "AIzaSyCs1dEUOfpICKD4prF89cSZs1tjOceC190";
    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public String getPolyline(double startLat, double startLon, double endLat, double endLon) {
        String url = String.format(
                "https://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&key=%s",
                startLat, startLon, endLat, endLon, API_KEY);

        try {
            String response = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(response);
            JsonNode routes = root.get("routes");
            if (routes != null && routes.isArray() && !routes.isEmpty()) {
                JsonNode overviewPolyline = routes.get(0).get("overview_polyline");
                if (overviewPolyline != null) {
                    return overviewPolyline.get("points").asText();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
