package com.renkotechnologie.backend.modules.booking.repository;

import com.renkotechnologie.backend.modules.booking.entity.InterventionPhoto;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface InterventionPhotoRepository extends JpaRepository<InterventionPhoto, Long> {

    List<InterventionPhoto> findByInterventionIdOrderByCreatedAtAsc(Long interventionId);
}
