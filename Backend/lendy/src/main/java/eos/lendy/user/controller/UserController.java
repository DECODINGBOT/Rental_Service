package eos.lendy.user.controller;

import eos.lendy.user.dto.UserProfileResponse;
import eos.lendy.user.dto.UserProfileUpdateRequest;
import eos.lendy.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/{id}")
    public UserProfileResponse getProfile(@PathVariable("id") Long id){
        return userService.getProfile(id);
    }

    @PatchMapping("/{id}")
    public UserProfileResponse updateProfile(@PathVariable("id") Long id, @RequestBody UserProfileUpdateRequest request){
        return userService.updateProfile(id, request);
    }

    @PostMapping("/{id}/profile-image")
    public UserProfileResponse updateProfileImage(@PathVariable("id") Long id, @RequestPart("image") MultipartFile image){
        return userService.updateProfileImage(id, image);
    }
}
