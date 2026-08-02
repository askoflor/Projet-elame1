package com.renkotechnologie.backend.modules.booking.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CompletionRequest {

    @NotBlank
    private String description;

    /** Photos du travail realise, encodees en base64 (data URI) ; au moins une est requise. */
    @NotEmpty
    private List<String> photos;
}
