package com.renkotechnologie.backend.modules.auth.service;

import com.renkotechnologie.backend.modules.auth.dto.AuthResponse;
import com.renkotechnologie.backend.modules.auth.dto.LoginRequest;
import com.renkotechnologie.backend.modules.auth.dto.RealisationPhotoRequest;
import com.renkotechnologie.backend.modules.auth.dto.RealisationPhotoResponse;
import com.renkotechnologie.backend.modules.auth.dto.RegisterRequest;
import com.renkotechnologie.backend.modules.auth.dto.UpdateProfileRequest;
import com.renkotechnologie.backend.modules.auth.dto.UserResponse;
import java.util.List;

public interface AuthService {

    AuthResponse register(RegisterRequest request);

    AuthResponse login(LoginRequest request);

    AuthResponse refresh(String refreshToken);

    UserResponse getCurrentUser(String email);

    UserResponse updateProfile(String email, UpdateProfileRequest request);

    void verifyEmail(String token);

    List<RealisationPhotoResponse> getRealisations(String email);

    RealisationPhotoResponse addRealisation(String email, RealisationPhotoRequest request);

    void deleteRealisation(String email, Long photoId);
}
