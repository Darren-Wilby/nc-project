package com.northcoders.customer;

public record CustomerRegistrationRequest(
        String name,
        String email,
        String password,
        Integer age
) {
}
