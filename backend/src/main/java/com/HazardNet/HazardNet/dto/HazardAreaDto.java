package com.HazardNet.HazardNet.dto;

import com.HazardNet.HazardNet.entity.HazardArea;
import com.HazardNet.HazardNet.entity.Role;
import jakarta.persistence.Column;
import lombok.Data;
import org.modelmapper.ModelMapper;

import java.util.Date;
import java.util.List;

@Data
public class HazardAreaDto {
    private Long id;
    private String name;
    private Double location_lat;
    private Double location_lon;
    private String city;
    private String district;
    private Date created_at;
    private String severity_level;
    private String radius_meters;

    // Full user details instead of just IDs
    private List<UserSimpleDetailsDto> users;

}

