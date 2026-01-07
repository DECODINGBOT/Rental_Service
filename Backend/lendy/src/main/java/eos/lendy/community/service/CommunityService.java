package eos.lendy.community.service;

import eos.lendy.community.dto.BoardRequest;
import eos.lendy.community.entity.BoardEntity;

public interface CommunityService {

    void create(BoardRequest boardRequest);

    void read();

    void fix();

    void delete();

    default BoardEntity requestToEntity(BoardRequest boardRequest) {
        //boardRequest로부터 BoardEntity return
        return null;
    }
}