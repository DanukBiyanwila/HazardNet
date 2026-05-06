package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.TrustedContacts;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TrustedContactsRepository extends JpaRepository<TrustedContacts, Long> {
    List<TrustedContacts> findByUserId(Long userId);
}