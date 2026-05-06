package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.EmergencyService;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmergencyServiceRepository extends JpaRepository<EmergencyService, Long> {
}