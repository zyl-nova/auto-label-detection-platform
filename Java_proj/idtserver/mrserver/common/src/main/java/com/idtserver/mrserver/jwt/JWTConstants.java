package com.idtserver.mrserver.jwt;

public class JWTConstants {
    public static final byte[] SECRET = System.getenv().getOrDefault("JWT_SECRET", "change-this-dev-secret-before-production").getBytes();
    public static final String TOKEN_HEADER = "Authorization";
    public static final String TOKEN_PREFIX = "Bearer ";
}
