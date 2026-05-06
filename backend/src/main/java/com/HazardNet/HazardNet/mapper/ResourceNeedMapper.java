package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.ResourceNeedDto;
import com.HazardNet.HazardNet.entity.ResourceNeed;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
@Mapper(componentModel = "spring")
public interface ResourceNeedMapper {


    @Mapping(source = "rescueCamp.id", target = "rescueCampId")
    @Mapping(source = "price_qty", target = "price_qty")
    ResourceNeedDto toDto(ResourceNeed resourceNeed);


    @Mapping(target = "rescueCamp", ignore = true)
    @Mapping(source = "price_qty", target = "price_qty")
    ResourceNeed toEntity(ResourceNeedDto resourceNeedDto);

    List<ResourceNeedDto> toDtoList(List<ResourceNeed> resourceNeeds);

    void updateResourceNeedFromDto(ResourceNeedDto dto, @MappingTarget ResourceNeed entity);

    List<ResourceNeed> toEntityList(List<ResourceNeedDto> dtos);
}
