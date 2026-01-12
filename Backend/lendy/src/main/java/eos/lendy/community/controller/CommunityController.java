package eos.lendy.community.controller;

import eos.lendy.community.dto.CommunityFixRequest;
import eos.lendy.community.dto.CommunityRequest;
import eos.lendy.community.dto.CommunityResponse;
import eos.lendy.community.service.CommunityService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class CommunityController {

    private final CommunityService communityService;

    @PostMapping("/create")
    public void create(@RequestBody CommunityRequest communityRequest){
        communityService.create(communityRequest);
    }

    @GetMapping("/board")
    public List<CommunityResponse> readBoards (){
        return communityService.readAll();
    }

    @GetMapping("/board/{id}")
    public CommunityResponse read(@PathVariable Long id){
        return communityService.read(id);
    }

    @PatchMapping("/{id}")
    public void fix(@RequestBody CommunityFixRequest communityFixRequest){
        communityService.fix(communityFixRequest);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id){
        communityService.delete(id);
    }
}
