package com.renkotechnologie.backend.modules.booking.dto;

import com.renkotechnologie.backend.modules.booking.entity.Intervention;
import java.time.LocalDate;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

/**
 * Entree "publique" du planning d'un prestataire : uniquement la date, les
 * heures occupees et le statut, sans aucune donnee client. Sert a griser les
 * creneaux deja pris lorsqu'un autre client consulte le calendrier de ce
 * prestataire pour reserver.
 */
@Getter
@Builder
@AllArgsConstructor
public class ProviderScheduleEntry {

    private LocalDate date;
    private List<Integer> heures;
    private String statut;

    public static ProviderScheduleEntry fromEntity(Intervention i) {
        return ProviderScheduleEntry.builder()
                .date(i.getDate())
                .heures(i.getHeures())
                .statut(i.getStatut().name())
                .build();
    }
}
