package com.HazardNet.HazardNet.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "donation_match")
public class DonationMatch {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "matched_quantity")
    private Integer matched_quantity;

    @Column(name = "match_date")
    private LocalDateTime match_date;


    @ManyToMany(mappedBy = "donationMatches", fetch = FetchType.EAGER)
    @JsonIgnoreProperties("donationMatches")
    private List<Donation> donations = new ArrayList<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "orphan_group_id", nullable = false)
    @JsonIgnoreProperties("donationMatches")
    private OrphanGroup orphanGroup;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rescue_camp_id", nullable = false)
    @JsonIgnoreProperties({"donationMatches", "orphanGroups", "resourceNeeds"})
    private RescueCamp rescueCamp;

}
