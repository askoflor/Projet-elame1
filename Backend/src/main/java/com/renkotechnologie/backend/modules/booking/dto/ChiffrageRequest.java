package com.renkotechnologie.backend.modules.booking.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ChiffrageRequest {

    @NotNull
    @Positive
    private Double montant;

    private LocalDate dateConfirmee;

    private String note;
}
