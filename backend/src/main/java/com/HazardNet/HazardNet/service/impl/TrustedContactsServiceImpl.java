package com.HazardNet.HazardNet.service.impl;

import com.HazardNet.HazardNet.dto.TrustedContactsDto;
import com.HazardNet.HazardNet.entity.TrustedContacts;
import com.HazardNet.HazardNet.entity.User;
import com.HazardNet.HazardNet.exception.NotFoundException;
import com.HazardNet.HazardNet.mapper.TrustedContactsMapper;
import com.HazardNet.HazardNet.repository.TrustedContactsRepository;
import com.HazardNet.HazardNet.repository.UserRepository;
import com.HazardNet.HazardNet.service.TrustedContactsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class TrustedContactsServiceImpl implements TrustedContactsService {

    private final TrustedContactsRepository trustedContactsRepository;
    private final TrustedContactsMapper trustedContactsMapper;
    private final UserRepository userRepository;

    @Override
    public TrustedContactsDto createTrustedContact(TrustedContactsDto trustedContactsDto) {
        TrustedContacts trustedContacts = trustedContactsMapper.toEntity(trustedContactsDto);

        // Fetch and attach user
        if (trustedContactsDto.getUserId() != null) {
            User user = userRepository.findById(trustedContactsDto.getUserId())
                    .orElseThrow(() -> new NotFoundException("User not found with ID: " + trustedContactsDto.getUserId()));
            trustedContacts.setUser(user);
        }

        TrustedContacts savedContact = trustedContactsRepository.save(trustedContacts);
        return trustedContactsMapper.toDto(savedContact);
    }

    @Override
    public List<TrustedContactsDto> getAllTrustedContacts() {
        List<TrustedContacts> contacts = trustedContactsRepository.findAll();
        return trustedContactsMapper.toDtoList(contacts);
    }

    @Override
    public TrustedContactsDto getTrustedContactById(Long id) {
        TrustedContacts trustedContacts = trustedContactsRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Trusted Contact not found with ID: " + id));
        return trustedContactsMapper.toDto(trustedContacts);
    }

    @Override
    public TrustedContactsDto updateTrustedContact(Long id, TrustedContactsDto trustedContactsDto) {
        TrustedContacts existingContact = trustedContactsRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Trusted Contact not found with ID: " + id));

        trustedContactsMapper.updateTrustedContactsFromDto(trustedContactsDto, existingContact);

        TrustedContacts savedContact = trustedContactsRepository.save(existingContact);
        return trustedContactsMapper.toDto(savedContact);
    }

    @Override
    public Boolean deleteTrustedContact(Long id) {
        if (!trustedContactsRepository.existsById(id)) {
            throw new NotFoundException("Trusted Contact not found with ID: " + id);
        }
        trustedContactsRepository.deleteById(id);
        return true;
    }

    @Override
    public List<TrustedContactsDto> getTrustedContactsByUserId(Long userId) {
        return trustedContactsRepository.findByUserId(userId).stream()
                .map(trustedContactsMapper::toDto)
                .toList();
    }
}