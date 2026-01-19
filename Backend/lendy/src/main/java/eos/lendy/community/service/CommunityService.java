package eos.lendy.community.service;

import eos.lendy.community.dto.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface CommunityService {
    CommunityDetailResponse create(CommunityRequest request, List<MultipartFile> images);
    CommunityDetailResponse read(Long id, Long userId);
    List<CommunityListResponse> readAllLatest();
    void fix(Long id, CommunityFixRequest request);
    void delete(Long id);
    CommentResponse addComment(Long boardId, CommentCreateRequest request);
    List<CommentResponse> listCommentsLatest(Long boardId);
    LikeToggleResponse toggleLike(Long boardId, Long userId);
}