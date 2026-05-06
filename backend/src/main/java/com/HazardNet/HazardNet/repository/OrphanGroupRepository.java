package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.OrphanGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface OrphanGroupRepository extends JpaRepository<OrphanGroup, Long> {

    List<OrphanGroup> findByRescueCamp_Id(Long rescueCampId);

}
