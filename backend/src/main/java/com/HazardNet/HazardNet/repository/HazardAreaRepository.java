package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.HazardArea;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HazardAreaRepository  extends JpaRepository<HazardArea, Long> {
}
