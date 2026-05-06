package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.RouteRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface RouteRequestRepository extends JpaRepository<RouteRequest, Long> {
}