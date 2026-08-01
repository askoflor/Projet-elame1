package com.renkotechnologie.backend.modules.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RealisationPhotoRequest {

    @NotBlank
    private String imageData;

    private String caption;
}
