package com.northcoders.auth;

public record AuthenticationRequest(
        String username,
        String password
) {
}
