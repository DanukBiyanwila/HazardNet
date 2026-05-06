package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.RescueCampDto;
import com.HazardNet.HazardNet.entity.RescueCamp;
import org.mapstruct.BeanMapping;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

@Mapper(componentModel = "spring",
        uses = {UserMapper.class, OrphanGroupMapper.class, ResourceNeedMapper.class})
public interface RescueCampMapper {

    @Mapping(source = "resourceNeeds", target = "resourceNeeds")
    @Mapping(source = "manager.id", target = "managerId")
    @Mapping(source = "people_image_url", target = "people_image_url")
    @Mapping(source = "address", target = "address")
    @Mapping(source = "tp_no", target = "tp_no")
    RescueCampDto toDto(RescueCamp rescueCamp);

    @Mapping(target = "manager", ignore = true)
    @Mapping(source = "people_image_url", target = "people_image_url")
    @Mapping(source = "address", target = "address")
    @Mapping(source = "tp_no", target = "tp_no")
    RescueCamp toEntity(RescueCampDto rescueCampDto);

    List<RescueCampDto> toDtoList(List<RescueCamp> rescueCamps);

    @BeanMapping(nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
    @Mapping(target = "id", ignore = true)
    @Mapping(target = "manager", ignore = true)
    @Mapping(target = "orphanGroups", ignore = true)
    @Mapping(target = "resourceNeeds", ignore = true)
    @Mapping(source = "people_image_url", target = "people_image_url")
    @Mapping(source = "address", target = "address")
    @Mapping(source = "tp_no", target = "tp_no")
    void updateRescueCampFromDto(RescueCampDto dto, @MappingTarget RescueCamp entity);

    List<RescueCamp> toEntityList(List<RescueCampDto> dtos);
}
