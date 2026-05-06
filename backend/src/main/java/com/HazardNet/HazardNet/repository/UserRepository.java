package com.HazardNet.HazardNet.repository;

import com.HazardNet.HazardNet.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    boolean existsByEmailAndIdNot(String email, Long id);
    boolean existsByEmail(String email);

    // Add this inside your UserRepository interface
    Optional<User> findByEmail(String email);

}
