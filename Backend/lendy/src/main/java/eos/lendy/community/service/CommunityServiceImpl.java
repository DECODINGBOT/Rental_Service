package eos.lendy.community.service;

import eos.lendy.community.dto.BoardRequest;
import eos.lendy.community.repository.BoardRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CommunityServiceImpl implements CommunityService {

    private final BoardRepository boardRepository;

    @Autowired
    public CommunityServiceImpl(BoardRepository boardRepository){
        this.boardRepository = boardRepository;
    }

    @Override
    public void create(BoardRequest boardRequest) {
        boardRepository.save(requestToEntity(boardRequest));
    }

    @Override
    public void read() {

    }

    @Override
    public void fix() {

    }

    @Override
    public void delete() {

    }
}
