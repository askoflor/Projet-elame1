package com.renkotechnologie.backend.modules.auth.repository;

import com.renkotechnologie.backend.modules.auth.entity.RealisationPhoto;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RealisationPhotoRepository extends JpaRepository<RealisationPhoto, Long> {

    List<RealisationPhoto> findByUserIdOrderByCreatedAtDesc(Long userId);
}
