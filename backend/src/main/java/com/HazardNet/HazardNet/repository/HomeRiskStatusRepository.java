package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.HomeRiskStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HomeRiskStatusRepository extends JpaRepository<HomeRiskStatus, Long> {

    List<HomeRiskStatus> findByHomeId(Long homeId);
}