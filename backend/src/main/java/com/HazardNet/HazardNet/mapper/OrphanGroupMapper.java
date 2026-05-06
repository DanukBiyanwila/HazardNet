package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.OrphanGroupDto; // Assuming this DTO exists
import com.HazardNet.HazardNet.entity.OrphanGroup; // Assuming this Entity exists
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface OrphanGroupMapper {

    @Mapping(target = "rescueCampId", source = "rescueCamp.id")
    OrphanGroupDto toDto(OrphanGroup orphanGroup);

    @Mapping(target = "rescueCamp", ignore = true)
    OrphanGroup toEntity(OrphanGroupDto orphanGroupDto);

    List<OrphanGroupDto> toDtoList(List<OrphanGroup> orphanGroups);

    void updateOrphanGroupFromDto(OrphanGroupDto dto, @MappingTarget OrphanGroup entity);

    List<OrphanGroup> toEntityList(List<OrphanGroupDto> dtos);
}
