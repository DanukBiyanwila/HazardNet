package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.MediaVerification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MediaVerificationRepository extends JpaRepository<MediaVerification, Long> {
}