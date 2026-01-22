package eos.lendy.community.service;

import eos.lendy.community.dto.*;
import eos.lendy.community.entity.*;
import eos.lendy.community.repository.*;
import eos.lendy.global.common.FileStorageService;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

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
    private final FileStorageService fileStorageService;

    @Transactional
    @Override
    public CommunityDetailResponse create(CommunityRequest request, List<MultipartFile> images) {
        String title = normalize(request.title());
        String content = normalize(request.content());
        Long userId = request.userId();

        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        CommunityEntity board = communityRepository.save(
                CommunityEntity.builder()
                        .title(title)
                        .content(content)
                        .user(user)
                        .build()
        );

        if(images != null){
            for(MultipartFile file : images){
                String url = fileStorageService.save(file);
                board.getImages().add(
                        BoardImageEntity.builder().board(board).imageUrl(url).build()
                );
            }
        }

        return toDetail(board, 0, 0, false, List.of());
    }

    @Override
    public CommunityDetailResponse read(Long id, Long userId) {
        CommunityEntity communityEntity = communityRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        long likeCount = boardLikeRepository.countByBoard_Id(id);
        long commentCount = commentRepository.countByBoard_Id(id);

        boolean liked = false;
        if(userId != null){
            liked = boardLikeRepository.existsByBoard_IdAndUser_Id(id, userId);
        }

        List<CommentResponse> comments = commentRepository.findByBoard_Id(
                id, Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(this::toCommentResponse)
                .toList();

        return toDetail(communityEntity, likeCount, commentCount, liked, comments);
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
        Long userId = request.userId();
        String content = normalize(request.content());

        if(userId == null){
            throw new IllegalArgumentException("userId is required");
        }
        if(content == null || content.isBlank()){
            throw new IllegalArgumentException("content is required");
        }

        CommunityEntity board = communityRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        CommentEntity saved = commentRepository.save(
                CommentEntity.builder()
                        .board(board)
                        .user(user)
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
    public LikeToggleResponse toggleLike(Long boardId, Long userId) {
        if(userId == null){
            throw new IllegalArgumentException("userId is required");
        }

        CommunityEntity board = communityRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("board not found"));

        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        boolean liked;
        if(boardLikeRepository.existsByBoard_IdAndUser_Id(boardId, userId)){
            boardLikeRepository.deleteByBoard_IdAndUser_Id(boardId, userId);
            liked = false;
        }else{
            boardLikeRepository.save(
                    BoardLikeEntity.builder()
                            .board(board)
                            .user(user)
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

    private CommunityDetailResponse toDetail(CommunityEntity communityEntity, long likeCount, long commentCount, boolean liked, List<CommentResponse> comments){
        List<String> imageUrls = communityEntity.getImages()
                .stream()
                .map(BoardImageEntity::getImageUrl)
                .toList();

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
                liked,
                comments,
                imageUrls
        );
    }

    private CommentResponse toCommentResponse(CommentEntity commentEntity){
        return new CommentResponse(
                commentEntity.getId(),
                commentEntity.getUser().getId(),
                commentEntity.getUser().getUsername(),
                commentEntity.getUser().getProfileImageUrl(),
                commentEntity.getContent(),
                commentEntity.getCreatedAt()
        );
    }

    private String normalize(String s){
        return s == null ? null : s.trim();
    }
}
