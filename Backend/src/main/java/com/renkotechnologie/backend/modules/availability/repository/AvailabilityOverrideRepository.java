package com.renkotechnologie.backend.modules.availability.repository;

import com.renkotechnologie.backend.modules.availability.entity.AvailabilityOverride;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AvailabilityOverrideRepository extends JpaRepository<AvailabilityOverride, Long> {

    List<AvailabilityOverride> findByProviderIdOrderByDateAsc(Long providerId);

    Optional<AvailabilityOverride> findByProviderIdAndDate(Long providerId, LocalDate date);

    List<AvailabilityOverride> findByProviderIdAndDateBetween(Long providerId, LocalDate start, LocalDate end);
}
