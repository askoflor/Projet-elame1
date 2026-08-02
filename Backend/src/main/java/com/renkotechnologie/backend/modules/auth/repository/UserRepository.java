package com.renkotechnologie.backend.modules.auth.repository;

import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);

    List<User> findByRole(Role role);
}
