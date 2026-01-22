package eos.lendy.transaction.repository;

import eos.lendy.transaction.entity.TransactionEntity;
import eos.lendy.transaction.entity.TransactionStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TransactionRepository extends JpaRepository<TransactionEntity, Long> {

    List<TransactionEntity> findByRenter_Id(Long renterUserId);

    List<TransactionEntity> findByOwner_Id(Long ownerUserId);

    List<TransactionEntity> findByStatus(TransactionStatus status);
}
