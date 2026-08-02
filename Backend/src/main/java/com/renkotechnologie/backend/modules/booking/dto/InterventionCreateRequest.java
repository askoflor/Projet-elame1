package com.renkotechnologie.backend.modules.booking.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InterventionCreateRequest {

    @NotBlank
    private String providerName;

    @NotBlank
    private String service;

    @NotBlank
    private String titre;

    private String description;

    @NotNull
    private LocalDate date;

    @NotEmpty
    private List<Integer> heures;

    @NotBlank
    private String urgence;

    @NotBlank
    private String adresse;
}
