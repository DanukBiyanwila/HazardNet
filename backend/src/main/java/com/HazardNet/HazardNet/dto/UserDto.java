package com.HazardNet.HazardNet.dto;


import lombok.Data;

import java.util.List;

@Data
public class UserDto {

    private Long id;

    private String name;

    private String email;

    private String password;

    private String imageUrl;

    private RoleSimpleDetilsDto role;

    private List<HazardAreaDto> hazardAreaDtos;

//    private List<RescueCampDto> managedCamps;

    private List<Long> homeIds;

    private List<Long> donationIds;

    private List<Long> routeAlertIds;

    private List<Long> medeaReportIds;

    private List<Long> mediaVerificationIds;

    private List<Long> routeRequestIds;




}
