package com.HazardNet.HazardNet.dto;

import lombok.Data;

@Data
public class UserSimpleDetailsDto {

    private Long id;
    private String name;
    private String email;
    private RoleSimpleDetilsDto role;
}
