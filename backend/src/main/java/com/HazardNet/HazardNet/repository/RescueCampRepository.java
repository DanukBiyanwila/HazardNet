package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.RescueCamp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RescueCampRepository extends JpaRepository<RescueCamp, Long> {
}
