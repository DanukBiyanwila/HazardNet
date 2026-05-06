package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class DonationDto {

    private Long id;

    private String item_type;

    private Integer quantity;

    private String status;

    private LocalDateTime created_at;

    private Long userId;

    private String name ;

    private List<Long> donationMatchIds;

}