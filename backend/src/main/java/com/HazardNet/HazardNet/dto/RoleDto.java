package com.HazardNet.HazardNet.dto;

import com.HazardNet.HazardNet.entity.Role;
import com.HazardNet.HazardNet.entity.User;
import lombok.Data;
import org.modelmapper.ModelMapper;

import java.util.List;

@Data
public class RoleDto {

    private Long id;

    private String name;
    private String dis;

    private List<Long> userIds;

}
