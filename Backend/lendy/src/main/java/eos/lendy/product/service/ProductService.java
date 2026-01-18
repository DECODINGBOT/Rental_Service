package eos.lendy.product.service;

import eos.lendy.product.dto.*;

import java.util.List;

public interface ProductService {

    ProductDetailResponse create(ProductCreateRequest request);

    ProductDetailResponse read(Long productId);

    List<ProductListResponse> readAllLatest();

    List<ProductListResponse> readMyProductsLatest(Long ownerUserId);

    void update(Long productId, ProductUpdateRequest request);

    void delete(Long productId);
}
