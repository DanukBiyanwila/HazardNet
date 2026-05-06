package com.HazardNet.HazardNet.dto;

import lombok.Data;

@Data
public class EmergencyServiceDto {
    private Long id;
    private String name;
    private String service_type;
    private Double location_lat;
    private Double location_lon;
    private String phone;
    private String address;
}