package com.HazardNet.HazardNet.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VisionResponseDto {
    @JsonProperty("people_count")
    private Integer peopleCount;
}
