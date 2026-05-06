package com.HazardNet.HazardNet.mapper;

import com.HazardNet.HazardNet.dto.TrustedContactsDto;
import com.HazardNet.HazardNet.entity.TrustedContacts;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrustedContactsMapper {

    @Mapping(target = "userId", source = "user.id")
    TrustedContactsDto toDto(TrustedContacts trustedContacts);

    @Mapping(target = "user", ignore = true)
    TrustedContacts toEntity(TrustedContactsDto trustedContactsDto);

    List<TrustedContactsDto> toDtoList(List<TrustedContacts> trustedContactsList);

    @Mapping(target = "user", ignore = true)
    void updateTrustedContactsFromDto(TrustedContactsDto dto, @MappingTarget TrustedContacts entity);

    List<TrustedContacts> toEntityList(List<TrustedContactsDto> dtos);
}