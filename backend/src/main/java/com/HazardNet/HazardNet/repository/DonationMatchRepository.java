package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.DonationMatch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DonationMatchRepository extends JpaRepository<DonationMatch, Long> {

    @Query("SELECT dm FROM DonationMatch dm " +
            "LEFT JOIN FETCH dm.donations " +
            "LEFT JOIN FETCH dm.orphanGroup " +
            "LEFT JOIN FETCH dm.rescueCamp")
    List<DonationMatch> findAllWithRelations();

    @Query("SELECT dm FROM DonationMatch dm " +
            "LEFT JOIN FETCH dm.donations " +
            "LEFT JOIN FETCH dm.orphanGroup " +
            "LEFT JOIN FETCH dm.rescueCamp " +
            "WHERE dm.id = :id")
    Optional<DonationMatch> findByIdWithRelations(@Param("id") Long id);
}