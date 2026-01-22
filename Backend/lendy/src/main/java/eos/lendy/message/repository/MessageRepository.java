package eos.lendy.message.repository;

import eos.lendy.message.entity.MessageEntity;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface MessageRepository extends JpaRepository<MessageEntity, Long> {

    List<MessageEntity> findByRoom_IdAndSentAtBeforeOrderBySentAtDesc(Long roomId, LocalDateTime before, Pageable pageable);

    List<MessageEntity> findByRoom_IdOrderBySentAtDesc(Long roomId, Pageable pageable);
}
