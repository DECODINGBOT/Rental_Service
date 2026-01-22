package eos.lendy.user.service;

import eos.lendy.auth.dto.LoginRequest;
import eos.lendy.auth.dto.SignUpRequest;
import eos.lendy.user.dto.*;
import org.springframework.web.multipart.MultipartFile;

public interface UserService {
    //UserResponse signUp(SignUpRequest request);
    //UserResponse login(LoginRequest request);
    UserProfileResponse getProfile(Long id);
    UserProfileResponse updateProfile(Long id, UserProfileUpdateRequest request);
    UserProfileResponse updateProfileImage(Long id, MultipartFile image);
}
