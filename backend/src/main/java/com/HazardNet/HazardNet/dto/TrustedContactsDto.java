package com.HazardNet.HazardNet.dto;

import lombok.Data;

@Data
public class TrustedContactsDto {
    private Long id;
    private String name;
    private String contact_phone;
    private String contact_email;
    private Long userId;
}