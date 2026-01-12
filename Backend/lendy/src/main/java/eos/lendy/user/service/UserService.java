package eos.lendy.user.service;

import eos.lendy.user.dto.*;

public interface UserService {
    UserResponse signUp(SignUpRequest request);
    UserResponse login(LoginRequest request);
    UserProfileResponse getProfile(Long id);
    UserProfileResponse updateProfile(Long id, UserProfileUpdateRequest request);
}
