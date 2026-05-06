package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.MediaReport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MediaReportRepository extends JpaRepository<MediaReport, Long> {
}