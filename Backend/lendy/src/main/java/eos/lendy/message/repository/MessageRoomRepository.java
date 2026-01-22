package eos.lendy.message.repository;

import eos.lendy.message.entity.MessageRoomEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MessageRoomRepository extends JpaRepository<MessageRoomEntity, Long> {

    Optional<MessageRoomEntity> findByTransaction_Id(Long transactionId);

    List<MessageRoomEntity> findByRenter_IdOrOwner_IdOrderByUpdatedAtDesc(Long renterId, Long ownerId);
}
