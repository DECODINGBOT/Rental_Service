package eos.lendy.product.dto;

import eos.lendy.product.entity.ProductStatus;
import java.time.LocalDateTime;

/**
 * Response model for product list view.
 */
public record ProductListResponse(
        Long id,
        String title,
        String category,
        Integer pricePerDay,
        Integer deposit,
        String location,
        String thumbnailUrl,
        ProductStatus status,
        Long ownerUserId,
        String ownerUsername,
        String ownerProfileImageUrl,
        LocalDateTime createdAt
) {}
