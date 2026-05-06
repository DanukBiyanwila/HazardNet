package com.HazardNet.HazardNet.controller;

import com.HazardNet.HazardNet.dto.TrustedContactsDto;
import com.HazardNet.HazardNet.service.TrustedContactsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("api/trusted_contacts")
@CrossOrigin(origins = "*")
public class TrustedContactsController {

    private final TrustedContactsService trustedContactsService;

    @PostMapping("/create")
    public ResponseEntity<TrustedContactsDto> createTrustedContact(@RequestBody TrustedContactsDto trustedContactsDto) {
        System.out.println("Trusted Contact Details: " + trustedContactsDto);
        TrustedContactsDto createdContact = trustedContactsService.createTrustedContact(trustedContactsDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdContact);
    }

    @GetMapping("/")
    public ResponseEntity<List<TrustedContactsDto>> getAllTrustedContacts() {
        List<TrustedContactsDto> contacts = trustedContactsService.getAllTrustedContacts();
        return ResponseEntity.status(HttpStatus.OK).body(contacts);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TrustedContactsDto> getTrustedContactById(@PathVariable Long id) {
        TrustedContactsDto contact = trustedContactsService.getTrustedContactById(id);
        return ResponseEntity.status(HttpStatus.OK).body(contact);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TrustedContactsDto> updateTrustedContact(@PathVariable Long id, @RequestBody TrustedContactsDto trustedContactsDto) {
        TrustedContactsDto updatedContact = trustedContactsService.updateTrustedContact(id, trustedContactsDto);
        return ResponseEntity.status(HttpStatus.OK).body(updatedContact);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Boolean> deleteTrustedContact(@PathVariable Long id) {
        Boolean isDeleted = trustedContactsService.deleteTrustedContact(id);
        return ResponseEntity.status(HttpStatus.OK).body(isDeleted);
    }

    @GetMapping("/by_user/{userId}")
    public ResponseEntity<List<TrustedContactsDto>> getTrustedContactsByUserId(@PathVariable Long userId) {
        List<TrustedContactsDto> contacts = trustedContactsService.getTrustedContactsByUserId(userId);
        return ResponseEntity.status(HttpStatus.OK).body(contacts);
    }
}