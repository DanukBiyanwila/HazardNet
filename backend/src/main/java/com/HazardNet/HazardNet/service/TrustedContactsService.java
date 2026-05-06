package com.HazardNet.HazardNet.service;

import com.HazardNet.HazardNet.dto.TrustedContactsDto;
import java.util.List;

public interface TrustedContactsService {

    TrustedContactsDto createTrustedContact(TrustedContactsDto trustedContactsDto);

    List<TrustedContactsDto> getAllTrustedContacts();

    TrustedContactsDto getTrustedContactById(Long id);

    TrustedContactsDto updateTrustedContact(Long id, TrustedContactsDto trustedContactsDto);

    Boolean deleteTrustedContact(Long id);

    List<TrustedContactsDto> getTrustedContactsByUserId(Long userId);
}