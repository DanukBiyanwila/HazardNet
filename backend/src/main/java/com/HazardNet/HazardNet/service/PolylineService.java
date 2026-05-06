package com.HazardNet.HazardNet.service;

import java.util.List;

public interface PolylineService {
    List<double[]> decode(String encoded);
    double calculateDistance(double lat1, double lon1, double lat2, double lon2);
}
