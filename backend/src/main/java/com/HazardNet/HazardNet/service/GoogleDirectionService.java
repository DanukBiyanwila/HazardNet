package com.HazardNet.HazardNet.service;

public interface GoogleDirectionService {
    String getPolyline(double startLat, double startLon, double endLat, double endLon);
}
