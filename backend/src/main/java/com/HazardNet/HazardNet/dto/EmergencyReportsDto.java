package com.HazardNet.HazardNet.dto;

import lombok.Data;
import java.util.List;

@Data
public class EmergencyReportsDto {
    private Long id;
    private String emergency_type;
    private Double location_lat;
    private Double location_lon;
    private String status;
    private String created_at;
    private Boolean is_show;
    private Long userId;

    private List<EmergencyServiceDto> nearestServices;
    private List<TrustedContactsDto> trustedContacts;
}