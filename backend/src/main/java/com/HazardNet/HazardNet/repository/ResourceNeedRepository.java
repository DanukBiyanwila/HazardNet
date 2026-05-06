package com.HazardNet.HazardNet.repository;


import com.HazardNet.HazardNet.entity.ResourceNeed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ResourceNeedRepository extends JpaRepository<ResourceNeed, Long> {
}
