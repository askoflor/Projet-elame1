package com.renkotechnologie.backend.modules.availability.dto;

import jakarta.validation.constraints.NotNull;
import java.time.LocalDate;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ToggleDateRequest {

    @NotNull
    private LocalDate date;
}
