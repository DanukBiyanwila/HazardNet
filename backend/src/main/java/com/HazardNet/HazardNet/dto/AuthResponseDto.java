package com.HazardNet.HazardNet.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AuthResponseDto {
    private String token; // This will hold your JWT token later
    private UserSimpleDetailsDto user;
}