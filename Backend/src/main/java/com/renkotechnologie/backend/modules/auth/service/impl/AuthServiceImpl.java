package com.renkotechnologie.backend.modules.auth.service.impl;

import com.renkotechnologie.backend.modules.auth.dto.AuthResponse;
import com.renkotechnologie.backend.modules.auth.dto.LoginRequest;
import com.renkotechnologie.backend.modules.auth.dto.RegisterRequest;
import com.renkotechnologie.backend.modules.auth.dto.UpdateProfileRequest;
import com.renkotechnologie.backend.modules.auth.dto.UserResponse;
import com.renkotechnologie.backend.modules.auth.entity.EmailVerificationToken;
import com.renkotechnologie.backend.modules.auth.entity.Role;
import com.renkotechnologie.backend.modules.auth.entity.User;
import com.renkotechnologie.backend.modules.auth.exception.EmailAlreadyUsedException;
import com.renkotechnologie.backend.modules.auth.exception.InvalidTokenException;
import com.renkotechnologie.backend.modules.auth.repository.EmailVerificationTokenRepository;
import com.renkotechnologie.backend.modules.auth.repository.UserRepository;
import com.renkotechnologie.backend.modules.auth.security.JwtService;
import com.renkotechnologie.backend.modules.auth.service.AuthService;
import com.renkotechnologie.backend.modules.auth.service.EmailService;
import java.time.LocalDateTime;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private static final int VERIFICATION_TOKEN_VALIDITY_HOURS = 24;

    private final UserRepository userRepository;
    private final EmailVerificationTokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final EmailService emailService;
    private final AuthenticationManager authenticationManager;

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new EmailAlreadyUsedException(request.getEmail());
        }

        Role role = Role.valueOf(request.getRole());
        User user = User.builder()
                .nom(request.getNom())
                .prenom(request.getPrenom())
                .email(request.getEmail())
                .telephone(request.getTelephone())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(role)
                .specialite(role == Role.PRESTATAIRE ? request.getSpecialite() : null)
                .dateNaissance(request.getDateNaissance())
                .emailVerified(false)
                .build();
        user = userRepository.save(user);

        sendVerificationEmail(user);

        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword()));

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new UsernameNotFoundException("Aucun utilisateur pour cet email"));
        return buildAuthResponse(user);
    }

    @Override
    public AuthResponse refresh(String refreshToken) {
        if (!jwtService.isRefreshToken(refreshToken)) {
            throw new InvalidTokenException("Jeton de rafraichissement invalide ou expire");
        }
        String email = jwtService.extractEmail(refreshToken);
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Aucun utilisateur pour cet email"));
        return buildAuthResponse(user);
    }

    @Override
    public UserResponse getCurrentUser(String email) {
        return UserResponse.fromEntity(findUserByEmail(email));
    }

    @Override
    @Transactional
    public UserResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = findUserByEmail(email);
        if (request.getNom() != null && !request.getNom().isBlank()) {
            user.setNom(request.getNom());
        }
        if (request.getPrenom() != null && !request.getPrenom().isBlank()) {
            user.setPrenom(request.getPrenom());
        }
        if (request.getTelephone() != null && !request.getTelephone().isBlank()) {
            user.setTelephone(request.getTelephone());
        }
        return UserResponse.fromEntity(userRepository.save(user));
    }

    @Override
    @Transactional
    public void verifyEmail(String token) {
        EmailVerificationToken verificationToken = tokenRepository.findByToken(token)
                .orElseThrow(() -> new InvalidTokenException("Lien de verification invalide"));

        if (verificationToken.isExpired()) {
            throw new InvalidTokenException("Lien de verification expire");
        }

        User user = verificationToken.getUser();
        user.setEmailVerified(true);
        userRepository.save(user);
        tokenRepository.delete(verificationToken);
    }

    private void sendVerificationEmail(User user) {
        String token = UUID.randomUUID().toString();
        EmailVerificationToken verificationToken = EmailVerificationToken.builder()
                .token(token)
                .user(user)
                .expiresAt(LocalDateTime.now().plusHours(VERIFICATION_TOKEN_VALIDITY_HOURS))
                .build();
        tokenRepository.save(verificationToken);
        emailService.sendVerificationEmail(user.getEmail(), user.getPrenom(), token);
    }

    private User findUserByEmail(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Aucun utilisateur pour cet email"));
    }

    private AuthResponse buildAuthResponse(User user) {
        return AuthResponse.builder()
                .token(jwtService.generateAccessToken(user))
                .refreshToken(jwtService.generateRefreshToken(user))
                .user(UserResponse.fromEntity(user))
                .build();
    }
}
