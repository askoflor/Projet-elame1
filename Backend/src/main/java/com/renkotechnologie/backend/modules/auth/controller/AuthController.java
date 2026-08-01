package com.renkotechnologie.backend.modules.auth.controller;

import com.renkotechnologie.backend.modules.auth.dto.AuthResponse;
import com.renkotechnologie.backend.modules.auth.dto.LoginRequest;
import com.renkotechnologie.backend.modules.auth.dto.RealisationPhotoRequest;
import com.renkotechnologie.backend.modules.auth.dto.RealisationPhotoResponse;
import com.renkotechnologie.backend.modules.auth.dto.RegisterRequest;
import com.renkotechnologie.backend.modules.auth.dto.UpdateProfileRequest;
import com.renkotechnologie.backend.modules.auth.dto.UserResponse;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.service.AuthService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestBody Map<String, String> body) {
        return ResponseEntity.ok(authService.refresh(body.get("refreshToken")));
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout() {
        // Jetons JWT sans etat : la deconnexion est geree cote client (suppression du jeton).
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<UserResponse> me(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(authService.getCurrentUser(user.getEmail()));
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponse> updateMe(
            @AuthenticationPrincipal User user,
            @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(authService.updateProfile(user.getEmail(), request));
    }

    @GetMapping("/verify-email")
    public ResponseEntity<Map<String, String>> verifyEmail(@RequestParam String token) {
        authService.verifyEmail(token);
        return ResponseEntity.ok(Map.of("message", "Adresse email verifiee avec succes"));
    }

    @GetMapping("/me/realisations")
    public ResponseEntity<List<RealisationPhotoResponse>> getRealisations(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(authService.getRealisations(user.getEmail()));
    }

    @PostMapping("/me/realisations")
    public ResponseEntity<RealisationPhotoResponse> addRealisation(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody RealisationPhotoRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.addRealisation(user.getEmail(), request));
    }

    @DeleteMapping("/me/realisations/{id}")
    public ResponseEntity<Void> deleteRealisation(@AuthenticationPrincipal User user, @PathVariable Long id) {
        authService.deleteRealisation(user.getEmail(), id);
        return ResponseEntity.noContent().build();
    }
}
