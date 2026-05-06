package com.HazardNet.HazardNet.dto;

import lombok.Data;

import java.util.List;

@Data
public class RescueCampDto {


    private Long id;

    private String name;

    private String address;

    private String tp_no;

    private Double location_lat;

    private Double location_lon;

    private Integer capacity;

    private Integer current_people_count;

    private Long managerId;

    private String people_image_url;

    private List<OrphanGroupDto> orphanGroups;

    private List<ResourceNeedDto> resourceNeeds;




}
