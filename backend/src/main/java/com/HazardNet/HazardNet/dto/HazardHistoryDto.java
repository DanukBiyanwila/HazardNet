package com.HazardNet.HazardNet.dto;

import jakarta.persistence.Column;
import lombok.Data;

@Data
public class HazardHistoryDto {

    private Long id;
    private String hazard_type;
    private Integer severity_level;
    private String occurred_time;
    private String dis;
    private Integer death_count;
    private Integer house_damage;

    private HazardAreaDto hazardArea;

}
