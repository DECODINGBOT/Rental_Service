package eos.lendy.community.controller;

import eos.lendy.community.dto.BoardRequest;
import eos.lendy.community.service.CommunityService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class CommunityController {

    private final CommunityService communityService;

    @Autowired
    public CommunityController(CommunityService communityService){
        this.communityService = communityService;
    }

    @PostMapping
    public void create(@RequestBody BoardRequest boardRequest){
        communityService.create(boardRequest);
    }
}
