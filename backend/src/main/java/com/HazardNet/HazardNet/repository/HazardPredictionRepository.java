package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.HazardPrediction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HazardPredictionRepository extends JpaRepository<HazardPrediction, Long> {


}
