package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.LocationResponseDTO;
import org.springframework.stereotype.Service;

public interface LocationService {

    LocationResponseDTO getLocationDetails(double lat, double lng);
}
