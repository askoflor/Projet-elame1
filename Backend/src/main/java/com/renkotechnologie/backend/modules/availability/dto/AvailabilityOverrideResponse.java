package com.renkotechnologie.backend.modules.availability.dto;

import com.renkotechnologie.backend.modules.availability.entity.AvailabilityOverride;
import java.time.LocalDate;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class AvailabilityOverrideResponse {

    private LocalDate date;
    private boolean disponible;

    public static AvailabilityOverrideResponse fromEntity(AvailabilityOverride override) {
        return AvailabilityOverrideResponse.builder()
                .date(override.getDate())
                .disponible(override.isDisponible())
                .build();
    }
}
