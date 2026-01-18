package eos.lendy.product.repository;

import eos.lendy.product.entity.ProductEntity;
import eos.lendy.product.entity.ProductStatus;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/**
 * Repository for accessing product data.
 */
public interface ProductRepository extends JpaRepository<ProductEntity, Long> {

    // Find products by status with sorting
    List<ProductEntity> findByStatus(ProductStatus status, Sort sort);

    // Find products owned by a specific user
    List<ProductEntity> findByOwner_Id(Long ownerUserId, Sort sort);
}
