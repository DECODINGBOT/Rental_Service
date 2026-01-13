package eos.lendy.community.controller;

import eos.lendy.community.dto.*;
import eos.lendy.community.service.CommunityService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/boards")
public class CommunityController {

    private final CommunityService communityService;

    @PostMapping
    public CommunityDetailResponse create(@RequestBody CommunityRequest request){
        return communityService.create(request);
    }

    @GetMapping
    public List<CommunityListResponse> readAllLatest(){
        return communityService.readAllLatest();
    }

    @GetMapping("/{id}")
    public CommunityDetailResponse read(@PathVariable Long id){
        return communityService.read(id);
    }

    @PatchMapping("/{id}")
    public void fix(@PathVariable Long id, @RequestBody CommunityFixRequest request){
        communityService.fix(id, request);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id){
        communityService.delete(id);
    }

    @PostMapping("/{id}/comments")
    public CommentResponse addComment(@PathVariable Long id, @RequestBody CommentCreateRequest request){
        return communityService.addComment(id, request);
    }

    @GetMapping("/{id}/comments")
    public List<CommentResponse> listCommentLatest(@PathVariable Long id){
        return communityService.listCommentsLatest(id);
    }

    @PostMapping("/{id}/likes/toggle")
    public LikeToggleResponse toggleLike(@PathVariable Long id, @RequestBody LikeToggleRequest request){
        if(request == null || request.username() == null){
            throw new IllegalArgumentException("username is required");
        }
        return communityService.toggleLike(id, request.username());
    }
}
