package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.RouteHazardCheck;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RouteHazardCheckRepository extends JpaRepository<RouteHazardCheck, Long> {
}