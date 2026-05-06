package com.HazardNet.HazardNet.mapper;

import java.util.List;

import com.HazardNet.HazardNet.dto.HazardHistoryDto;
import com.HazardNet.HazardNet.entity.HazardHistory;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;


@Mapper(componentModel = "spring", uses = {HazardAreaMapper.class})
public interface HazardHistoryMapper {


    HazardHistoryDto toDto(HazardHistory hazardHistory);

    @Mapping(target = "hazardArea", ignore = true)
    HazardHistory toEntity(HazardHistoryDto hazardHistoryDto);

    List<HazardHistoryDto> toDtoList(List<HazardHistory> hazardHistories);

    @Mapping(target = "hazardArea", ignore = true)
    void updateHazardHistoryFromDto(HazardHistoryDto dto, @MappingTarget HazardHistory entity);

    List<HazardHistory> toEntityList(List<HazardHistoryDto> dtos);
}