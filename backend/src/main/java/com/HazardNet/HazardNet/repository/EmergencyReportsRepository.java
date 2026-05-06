package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.EmergencyReports;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmergencyReportsRepository extends JpaRepository<EmergencyReports, Long> {
}