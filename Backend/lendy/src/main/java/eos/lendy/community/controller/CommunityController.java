package eos.lendy.community.controller;

import eos.lendy.community.dto.*;
import eos.lendy.community.service.CommunityService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/boards")
public class CommunityController {

    private final CommunityService communityService;

    @PostMapping(consumes = "multipart/form-data")
    public CommunityDetailResponse create(
            @RequestPart("request") CommunityRequest request,
            @RequestPart(value = "images", required = false) List<MultipartFile> images
    ){
        return communityService.create(request, images);
    }

    @GetMapping
    public List<CommunityListResponse> readAllLatest(){
        return communityService.readAllLatest();
    }

    @GetMapping("/{id}")
    public CommunityDetailResponse read(@PathVariable("id") Long id, @RequestParam(value = "userId", required = false) Long userId){
        return communityService.read(id, userId);
    }

    @PatchMapping("/{id}")
    public void fix(@PathVariable("id") Long id, @RequestBody CommunityFixRequest request){
        communityService.fix(id, request);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable("id") Long id){
        communityService.delete(id);
    }

    @PostMapping("/{id}/comments")
    public CommentResponse addComment(@PathVariable("id") Long id, @RequestBody CommentCreateRequest request){
        return communityService.addComment(id, request);
    }

    @GetMapping("/{id}/comments")
    public List<CommentResponse> listCommentLatest(@PathVariable("id") Long id){
        return communityService.listCommentsLatest(id);
    }

    @PostMapping("/{id}/likes/toggle")
    public LikeToggleResponse toggleLike(@PathVariable("id") Long id, @RequestBody LikeToggleRequest request){
        if(request == null || request.userId() == null){
            throw new IllegalArgumentException("userId is required");
        }
        return communityService.toggleLike(id, request.userId());
    }
}
