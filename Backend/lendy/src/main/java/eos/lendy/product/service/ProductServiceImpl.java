package eos.lendy.product.service;

import eos.lendy.global.storage.StorageService;
import eos.lendy.product.dto.*;
import eos.lendy.product.entity.ProductEntity;
import eos.lendy.product.entity.ProductStatus;
import eos.lendy.product.repository.ProductRepository;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ProductServiceImpl implements ProductService {

    private final ProductRepository productRepository;
    private final UserRepository userRepository;
    private final StorageService storageService;

    @Transactional
    @Override
    public ProductDetailResponse create(ProductCreateRequest request) {
        String title = normalize(request.title());
        String description = normalize(request.description());
        String category = normalize(request.category());
        Integer pricePerDay = request.pricePerDay();
        Integer deposit = request.deposit();
        String location = normalize(request.location());
        String thumbnailUrl = normalize(request.thumbnailUrl());
        Long ownerUserId = request.ownerUserId();

        if (title == null || title.isBlank()) throw new IllegalArgumentException("title is required");
        if (description == null || description.isBlank()) throw new IllegalArgumentException("description is required");
        if (category == null || category.isBlank()) throw new IllegalArgumentException("category is required");
        if (pricePerDay == null || pricePerDay < 0) throw new IllegalArgumentException("pricePerDay must be >= 0");
        if (deposit == null || deposit < 0) throw new IllegalArgumentException("deposit must be >= 0");
        if (location == null || location.isBlank()) throw new IllegalArgumentException("location is required");
        if (ownerUserId == null) throw new IllegalArgumentException("ownerUserId is required");

        UserEntity owner = userRepository.findById(ownerUserId)
                .orElseThrow(() -> new IllegalArgumentException("user not found"));

        ProductEntity saved = productRepository.save(
                ProductEntity.builder()
                        .title(title)
                        .description(description)
                        .category(category)
                        .pricePerDay(pricePerDay)
                        .deposit(deposit)
                        .location(location)
                        .thumbnailUrl(thumbnailUrl)
                        .status(ProductStatus.AVAILABLE)
                        .owner(owner)
                        .build()
        );

        return toDetail(saved);
    }

    @Override
    public ProductDetailResponse read(Long productId) {
        ProductEntity p = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("product not found"));
        return toDetail(p);
    }

    @Override
    public List<ProductListResponse> readAllLatest() {
        return productRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(this::toList)
                .toList();
    }

    @Override
    public List<ProductListResponse> readMyProductsLatest(Long ownerUserId) {
        if (ownerUserId == null) throw new IllegalArgumentException("ownerUserId is required");

        if (!userRepository.existsById(ownerUserId)) {
            throw new IllegalArgumentException("user not found");
        }

        return productRepository.findByOwner_Id(ownerUserId, Sort.by(Sort.Direction.DESC, "createdAt"))
                .stream()
                .map(this::toList)
                .toList();
    }

    @Transactional
    @Override
    public void update(Long productId, ProductUpdateRequest request) {
        ProductEntity p = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("product not found"));

        String title = request.title();
        String description = request.description();
        String category = request.category();
        Integer pricePerDay = request.pricePerDay();
        Integer deposit = request.deposit();
        String location = request.location();
        String thumbnailUrl = request.thumbnailUrl();
        ProductStatus status = request.status();

        if (title != null && title.isBlank()) throw new IllegalArgumentException("title must not be blank");
        if (description != null && description.isBlank()) throw new IllegalArgumentException("description must not be blank");
        if (category != null && category.isBlank()) throw new IllegalArgumentException("category must not be blank");
        if (pricePerDay != null && pricePerDay < 0) throw new IllegalArgumentException("pricePerDay must be >= 0");
        if (deposit != null && deposit < 0) throw new IllegalArgumentException("deposit must be >= 0");
        if (location != null && location.isBlank()) throw new IllegalArgumentException("location must not be blank");

        p.update(
                title == null ? null : title.trim(),
                description == null ? null : description.trim(),
                category == null ? null : category.trim(),
                pricePerDay,
                deposit,
                location == null ? null : location.trim(),
                thumbnailUrl == null ? null : thumbnailUrl.trim(),
                status
        );
    }

    @Transactional
    @Override
    public void delete(Long productId) {
        if (!productRepository.existsById(productId)) {
            throw new IllegalArgumentException("product not found");
        }
        productRepository.deleteById(productId);

        // Best-effort cleanup for stored images
        storageService.deleteProductFolder(productId);
    }

    @Transactional
    @Override
    public ProductThumbnailUploadResponse uploadThumbnail(Long productId, MultipartFile file) {
        ProductEntity p = productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("product not found"));

        String url = storageService.storeProductThumbnail(productId, file);

        p.update(
                null, null, null, null, null, null,
                url,
                null
        );

        return new ProductThumbnailUploadResponse(productId, url);
    }

    private ProductListResponse toList(ProductEntity p) {
        return new ProductListResponse(
                p.getId(),
                p.getTitle(),
                p.getCategory(),
                p.getPricePerDay(),
                p.getDeposit(),
                p.getLocation(),
                p.getThumbnailUrl(),
                p.getStatus(),
                p.getOwner().getUsername(),
                p.getOwner().getProfileImageUrl(),
                p.getCreatedAt()
        );
    }

    private ProductDetailResponse toDetail(ProductEntity p) {
        return new ProductDetailResponse(
                p.getId(),
                p.getTitle(),
                p.getDescription(),
                p.getCategory(),
                p.getPricePerDay(),
                p.getDeposit(),
                p.getLocation(),
                p.getThumbnailUrl(),
                p.getStatus(),
                p.getOwner().getId(),
                p.getOwner().getUsername(),
                p.getOwner().getProfileImageUrl(),
                p.getCreatedAt(),
                p.getUpdatedAt()
        );
    }

    private String normalize(String s) {
        return s == null ? null : s.trim();
    }
}
