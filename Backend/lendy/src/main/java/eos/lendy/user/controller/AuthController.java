package eos.lendy.user.controller;

import eos.lendy.user.dto.LoginRequest;
import eos.lendy.user.dto.SignUpRequest;
import eos.lendy.user.dto.UserResponse;
import eos.lendy.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @PostMapping("/signup")
    public UserResponse signUp(@RequestBody SignUpRequest request){
        return userService.signUp(request);
    }

    @PostMapping("/login")
    public UserResponse login(@RequestBody LoginRequest request){
        return userService.login(request);
    }
}
