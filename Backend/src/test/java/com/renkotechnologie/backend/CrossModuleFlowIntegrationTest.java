package com.renkotechnologie.backend;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.renkotechnologie.backend.modules.auth.dto.RegisterRequest;
import com.renkotechnologie.backend.modules.availability.dto.ToggleDateRequest;
import com.renkotechnologie.backend.modules.booking.dto.ChiffrageRequest;
import com.renkotechnologie.backend.modules.booking.dto.CompletionRequest;
import com.renkotechnologie.backend.modules.booking.dto.InterventionCreateRequest;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

/**
 * Verifie de bout en bout, via l'API HTTP (MockMvc + H2), que le decouplage
 * entre modules (UserPrincipal en lieu et place de l'entite User, UserDirectoryService,
 * suppression des relations JPA inter-modules sur Intervention/AvailabilityOverride,
 * search qui passe desormais par AvailabilityService/InterventionService) n'a
 * introduit aucune regression fonctionnelle sur le parcours client/prestataire.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class CrossModuleFlowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void parcoursCompletClientEtPrestataire() throws Exception {
        RegisterRequest clientRegister = new RegisterRequest();
        clientRegister.setNom("Mbarga");
        clientRegister.setPrenom("Alice");
        clientRegister.setEmail("alice.client@test.local");
        clientRegister.setPassword("Secret123");
        clientRegister.setRole("CLIENT");
        clientRegister.setTelephone("690000001");
        String clientToken = register(clientRegister);

        RegisterRequest providerRegister = new RegisterRequest();
        providerRegister.setNom("Eto'o");
        providerRegister.setPrenom("Bruno");
        providerRegister.setEmail("bruno.provider@test.local");
        providerRegister.setPassword("Secret123");
        providerRegister.setRole("PRESTATAIRE");
        providerRegister.setTelephone("690000002");
        providerRegister.setSpecialite("Plomberie");
        String providerToken = register(providerRegister);
        String providerDisplayName = "Bruno Eto'o";

        // GET /auth/me : verifie que le JwtAuthenticationFilter + UserPrincipal
        // (nouveau principal leger qui remplace l'entite User) fonctionnent toujours.
        mockMvc.perform(get("/api/v1/auth/me").header("Authorization", bearer(providerToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("bruno.provider@test.local"))
                .andExpect(jsonPath("$.role").value("PRESTATAIRE"));

        // Le prestataire se declare indisponible demain : ecrit AvailabilityOverride.providerId
        // (plus de relation JPA vers User) via UserDirectoryService pour resoudre son id.
        LocalDate demain = LocalDate.now().plusDays(1);
        ToggleDateRequest toggle = new ToggleDateRequest();
        toggle.setDate(demain);
        mockMvc.perform(post("/api/v1/availability/toggle")
                        .header("Authorization", bearer(providerToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(toggle)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].date").value(demain.toString()))
                .andExpect(jsonPath("$[0].disponible").value(false));

        // Recherche publique (endpoint anonyme) : le prestataire apparait, 0 mission realisee.
        mockMvc.perform(get("/api/v1/search/providers").param("specialite", "Plomberie"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].prenom").value("Bruno"))
                .andExpect(jsonPath("$[0].missionsRealisees").value(0));

        // Avec le filtre de date sur "demain" : exclu, car AvailabilityService.estDisponibleLe
        // (appele depuis SearchServiceImpl via l'interface, plus via le repository direct) le signale indisponible.
        mockMvc.perform(get("/api/v1/search/providers")
                        .param("specialite", "Plomberie")
                        .param("date", demain.toString()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(0));

        // Le client cree une intervention : ecrit Intervention.clientId (plus de relation JPA),
        // la reponse doit quand meme contenir le nom/telephone du client, resolus via UserDirectoryService.
        InterventionCreateRequest creation = new InterventionCreateRequest();
        creation.setProviderName(providerDisplayName);
        creation.setService("Plomberie");
        creation.setTitre("Fuite sous evier");
        creation.setDate(LocalDate.now().plusDays(2));
        creation.setHeures(List.of(9, 10));
        creation.setUrgence("NORMALE");
        creation.setAdresse("Quartier Bastos, Yaounde");

        MvcResult creationResult = mockMvc.perform(post("/api/v1/interventions")
                        .header("Authorization", bearer(clientToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(creation)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.clientNom").value("Alice Mbarga"))
                .andExpect(jsonPath("$.clientPhone").value("690000001"))
                .andExpect(jsonPath("$.statut").value("ATTENTE"))
                .andReturn();
        String reference = objectMapper.readTree(creationResult.getResponse().getContentAsString())
                .get("reference").asText();

        mockMvc.perform(get("/api/v1/interventions/mine/client").header("Authorization", bearer(clientToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].reference").value(reference));

        mockMvc.perform(get("/api/v1/interventions/mine/prestataire").header("Authorization", bearer(providerToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].reference").value(reference));

        ChiffrageRequest chiffrage = new ChiffrageRequest();
        chiffrage.setMontant(15000.0);
        mockMvc.perform(post("/api/v1/interventions/" + reference + "/chiffrer")
                        .header("Authorization", bearer(providerToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(chiffrage)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.statut").value("ENCOURS"))
                .andExpect(jsonPath("$.montant").value(15000.0));

        CompletionRequest completion = new CompletionRequest();
        completion.setDescription("Fuite reparee");
        completion.setPhotos(List.of("data:image/png;base64,iVBORw0KGgo="));
        mockMvc.perform(post("/api/v1/interventions/" + reference + "/terminer")
                        .header("Authorization", bearer(providerToken))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(completion)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.statut").value("TERMINEE"))
                .andExpect(jsonPath("$.completionPhotos.length()").value(1));

        // La mission terminee doit maintenant remonter dans le compteur du module search
        // (InterventionService.compterMissionsTerminees, appele via l'interface publique du module booking).
        mockMvc.perform(get("/api/v1/search/providers").param("specialite", "Plomberie"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].missionsRealisees").value(1));
    }

    private String register(RegisterRequest request) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/v1/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andReturn();
        JsonNode body = objectMapper.readTree(result.getResponse().getContentAsString());
        return body.get("token").asText();
    }

    private String bearer(String token) {
        return "Bearer " + token;
    }
}
