package eos.lendy.product.dto;

import eos.lendy.product.entity.ProductStatus;
import java.time.LocalDateTime;

/**
 * Response model for product detail view.
 */
public record ProductDetailResponse(
        Long id,
        String title,
        String description,
        String category,
        Integer pricePerDay,
        Integer deposit,
        String location,
        String thumbnailUrl,
        ProductStatus status,
        Long ownerUserId,
        String ownerUsername,
        String ownerProfileImageUrl,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {}
