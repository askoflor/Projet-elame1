package com.renkotechnologie.backend.modules.auth.dto;

import com.renkotechnologie.backend.modules.auth.entity.RealisationPhoto;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class RealisationPhotoResponse {

    private String id;
    private String imageData;
    private String caption;

    public static RealisationPhotoResponse fromEntity(RealisationPhoto photo) {
        return RealisationPhotoResponse.builder()
                .id(String.valueOf(photo.getId()))
                .imageData(photo.getImageData())
                .caption(photo.getCaption())
                .build();
    }
}
