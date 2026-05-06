package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.HazardHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HazardHistoryRepository  extends JpaRepository<HazardHistory, Long> {

}
