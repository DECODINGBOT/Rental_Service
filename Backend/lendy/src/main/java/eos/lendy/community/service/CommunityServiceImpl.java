package eos.lendy.community.service;

import eos.lendy.community.dto.*;
import eos.lendy.community.entity.BoardLikeEntity;
import eos.lendy.community.entity.CommentEntity;
import eos.lendy.community.entity.CommunityEntity;
import eos.lendy.community.repository.BoardCountProjection;
import eos.lendy.community.repository.BoardLikeRepository;
import eos.lendy.community.repository.CommentRepository;
import eos.lendy.community.repository.CommunityRepository;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CommunityServiceImpl implements CommunityService {

    private final CommunityRepository communityRepository;
    private final CommentRepository commentRepository;
    private final BoardLikeRepository boardLikeRepository;
    private final UserRepository userRepository;

    @Transactional
    @Override
    public CommunityDetailResponse create(CommunityRequest request) {
        String title = normalize(request.title());
        String content = normalize(request.content());
        Long userId = request.userId();

        if(title == null || title.isBlank()){
            throw new IllegalArgumentException("title is required");
        }
        if(content == null || content.isBlank()){
            throw new IllegalArgumentException("content is required");
        }
        if(userId == null){
            throw new IllegalArgumentException("userId is required");
        }

        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        CommunityEntity saved = communityRepository.save(
                CommunityEntity.builder()
                        .title(title)
                        .content(content)
                        .user(user)
                        .build()
        );
        return toDetail(saved, 0, 0, List.of());
    }

    @Override
    public CommunityDetailResponse read(Long id) {
        CommunityEntity communityEntity = communityRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        long likeCount = boardLikeRepository.countByBoard_Id(id);
        long commentCount = commentRepository.countByBoard_Id(id);

        List<CommentResponse> comments = commentRepository.findByBoard_Id(
                id, Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(this::toCommentResponse)
                .toList();

        return toDetail(communityEntity, likeCount, commentCount, comments);
    }

    @Override
    public List<CommunityListResponse> readAllLatest() {
        List<CommunityEntity> boards = communityRepository.findAll(
                Sort.by(Sort.Direction.DESC, "createdAt")
        );

        if(boards.isEmpty()){
            return List.of();
        }
        List<Long> ids = boards.stream().map(CommunityEntity::getId).toList();

        Map<Long, Long> likeCounts = boardLikeRepository.countByBoardIds(ids).stream()
                .collect(Collectors.toMap(BoardCountProjection::getBoardId, BoardCountProjection::getCnt));

        Map<Long, Long> commentCounts = commentRepository.countByBoardIds(ids).stream()
                .collect(Collectors.toMap(BoardCountProjection::getBoardId, BoardCountProjection::getCnt));

        return boards.stream()
                .map(b -> toList(
                        b,
                        likeCounts.getOrDefault(b.getId(), 0L),
                        commentCounts.getOrDefault(b.getId(), 0L)
                )).toList();
        /*
        return communityRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(e -> {
                    long likeCount = boardLikeRepository.countByBoard_Id(e.getId());
                    long commentCount = commentRepository.countByBoard_Id(e.getId());
                    return toList(e, likeCount, commentCount);
                })
                .toList();
         */
    }

    @Transactional
    @Override
    public void fix(Long id, CommunityFixRequest request) {
        CommunityEntity communityEntity = communityRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        String title = request.title();
        String content = request.content();

        if(title != null && title.isBlank()){
            throw new IllegalArgumentException("title must not be blank");
        }
        if(content != null && content.isBlank()){
            throw new IllegalArgumentException("content must not be blank");
        }
        communityEntity.update(
                title == null ? null : title.trim(),
                content == null ? null : content.trim()
        );
    }

    @Override
    public void delete(Long id) {
        if(!communityRepository.existsById(id)){
            throw new IllegalArgumentException("board not found");
        }
        communityRepository.deleteById(id);
    }

    @Transactional
    @Override
    public CommentResponse addComment(Long boardId, CommentCreateRequest request) {
        String username = normalize(request.username());
        String content = normalize(request.content());

        if(username == null || username.isBlank()){
            throw new IllegalArgumentException("username is required");
        }
        if(content == null || content.isBlank()){
            throw new IllegalArgumentException("content is required");
        }

        CommunityEntity board = communityRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        CommentEntity saved = commentRepository.save(
                CommentEntity.builder()
                        .board(board)
                        .username(username)
                        .content(content)
                        .build()
        );

        return toCommentResponse(saved);
    }

    @Override
    public List<CommentResponse> listCommentsLatest(Long boardId) {
        if(!communityRepository.existsById(boardId)){
            throw new IllegalArgumentException("board not found");
        }
        return commentRepository.findByBoard_Id(boardId, Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(this::toCommentResponse)
                .toList();
    }

    @Transactional
    @Override
    public LikeToggleResponse toggleLike(Long boardId, String usernameRaw) {
        String username = normalize(usernameRaw);
        if(username == null || username.isBlank()){
            throw new IllegalArgumentException("username is required");
        }

        CommunityEntity board = communityRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        boolean liked;
        if(boardLikeRepository.existsByBoard_IdAndUsername(boardId, username)){
            boardLikeRepository.deleteByBoard_IdAndUsername(boardId, username);
            liked = false;
        }else{
            boardLikeRepository.save(
                    BoardLikeEntity.builder()
                            .board(board)
                            .username(username)
                            .build()
            );
            liked = true;
        }

        long likeCount = boardLikeRepository.countByBoard_Id(boardId);
        return new LikeToggleResponse(liked, likeCount);
    }

    private CommunityListResponse toList(CommunityEntity communityEntity, long likeCount, long commentCount){
        String preview = communityEntity.getContent();
        if(preview == null) {
            preview = "";
        }
        preview = preview.replace("\n", " ").trim();
        if(preview.length() > 30){
            preview = preview.substring(0, 30) + "...";
        }

        return new CommunityListResponse(
                communityEntity.getId(),
                communityEntity.getTitle(),
                preview,
                communityEntity.getUser().getUsername(),
                communityEntity.getUser().getProfileImageUrl(),
                communityEntity.getCreatedAt(),
                likeCount,
                commentCount
        );
    }

    private CommunityDetailResponse toDetail(CommunityEntity communityEntity, long likeCount, long commentCount, List<CommentResponse> comments){
        return new CommunityDetailResponse(
                communityEntity.getId(),
                communityEntity.getTitle(),
                communityEntity.getContent(),
                communityEntity.getUser().getUsername(),
                communityEntity.getUser().getProfileImageUrl(),
                communityEntity.getCreatedAt(),
                communityEntity.getUpdatedAt(),
                likeCount,
                commentCount,
                comments
        );
    }

    private CommentResponse toCommentResponse(CommentEntity commentEntity){
        return new CommentResponse(
                commentEntity.getId(),
                commentEntity.getUsername(),
                commentEntity.getContent(),
                commentEntity.getCreatedAt()
        );
    }

    private String normalize(String s){
        return s == null ? null : s.trim();
    }
}
