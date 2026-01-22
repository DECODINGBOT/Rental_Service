package eos.lendy.product.dto;

import eos.lendy.product.entity.ProductStatus;

/**
 * Request payload for updating an existing product.
 * All fields are optional to support partial updates.
 */
public record ProductUpdateRequest(
        String title,
        String description,
        String category,
        Integer pricePerDay,
        Integer deposit,
        String location,
        String thumbnailUrl,
        ProductStatus status
) {}
