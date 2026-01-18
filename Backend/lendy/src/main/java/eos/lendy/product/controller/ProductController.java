package eos.lendy.product.controller;

import eos.lendy.product.dto.*;
import eos.lendy.product.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/products")
public class ProductController {

    private final ProductService productService;

    @PostMapping
    public ProductDetailResponse create(@RequestBody ProductCreateRequest request) {
        return productService.create(request);
    }

    @GetMapping
    public List<ProductListResponse> readAllLatest() {
        return productService.readAllLatest();
    }

    @GetMapping("/my")
    public List<ProductListResponse> readMyProductsLatest(@RequestParam Long ownerUserId) {
        return productService.readMyProductsLatest(ownerUserId);
    }

    @GetMapping("/{id}")
    public ProductDetailResponse read(@PathVariable Long id) {
        return productService.read(id);
    }

    @PatchMapping("/{id}")
    public void update(@PathVariable Long id, @RequestBody ProductUpdateRequest request) {
        productService.update(id, request);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        productService.delete(id);
    }
}
