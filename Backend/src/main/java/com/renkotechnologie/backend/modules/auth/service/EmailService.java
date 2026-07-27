package com.renkotechnologie.backend.modules.auth.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

/**
 * Envoi des emails transactionnels du module auth (verification d'adresse email).
 * Un echec d'envoi n'interrompt jamais l'inscription : il est journalise et avale,
 * pour que la creation de compte reste fonctionnelle meme si le SMTP n'est pas
 * (encore) configure.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:}")
    private String fromAddress;

    @Value("${app.mail.verification-base-url}")
    private String verificationBaseUrl;

    public void sendVerificationEmail(String to, String prenom, String token) {
        String link = verificationBaseUrl + "?token=" + token;
        String body = "Bonjour " + prenom + ",\n\n"
                + "Merci de vous etre inscrit(e) sur NZELA-SERVICE.\n\n"
                + "Veuillez confirmer votre adresse email en ouvrant ce lien :\n"
                + link + "\n\n"
                + "Ce lien expire dans 24 heures.\n\n"
                + "Si vous n'etes pas a l'origine de cette inscription, vous pouvez ignorer ce message.";

        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromAddress);
            message.setTo(to);
            message.setSubject("Confirmez votre adresse email - NZELA-SERVICE");
            message.setText(body);
            mailSender.send(message);
        } catch (Exception e) {
            log.warn("Echec de l'envoi de l'email de verification a {} : {}", to, e.getMessage());
        }
    }
}
