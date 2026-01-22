package eos.lendy.auth.controller;

import eos.lendy.auth.dto.*;
import eos.lendy.auth.service.AuthService;
import eos.lendy.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    public UserResponse signUp(@RequestBody SignUpRequest request){
        return authService.signUp(request);
    }

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request){
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public RefreshResponse refresh(@RequestBody RefreshRequest request){
        return authService.refresh(request);
    }

    @PostMapping("/logout")
    public void logout(@RequestBody LogoutRequest request){
        authService.logout(request);
    }
}
