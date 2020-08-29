package com.austindewey.springcloudclient.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RefreshScope
public class MainController {

    @Value("${username}")
    private String username;
    
    @RequestMapping("/")
    public String index() {
        return "Hello! This is a Spring Boot app used for demo purposes!";
    }

    @RequestMapping("/get")
    public String get() {
        return username;
    }
}