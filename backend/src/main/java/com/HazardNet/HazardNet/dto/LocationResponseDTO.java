package com.HazardNet.HazardNet.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class LocationResponseDTO {

    private String city;
    private String district;
    private String country;

}
