package eos.lendy.message.service;

import eos.lendy.message.dto.MessageResponse;
import eos.lendy.message.dto.RoomResponse;
import eos.lendy.message.entity.MessageEntity;
import eos.lendy.message.entity.MessageRoomEntity;
import eos.lendy.message.repository.MessageRepository;
import eos.lendy.message.repository.MessageRoomRepository;
import eos.lendy.transaction.entity.TransactionEntity;
import eos.lendy.transaction.repository.TransactionRepository;
import eos.lendy.user.entity.UserEntity;
import eos.lendy.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MessageService {

    private static final int DEFAULT_PAGE_SIZE = 50;

    private final MessageRoomRepository roomRepository;
    private final MessageRepository messageRepository;
    private final TransactionRepository transactionRepository;
    private final UserRepository userRepository;

    @Transactional
    public RoomResponse createOrGetRoomByTransaction(Long transactionId, Long requesterId) {
        MessageRoomEntity existing = roomRepository.findByTransaction_Id(transactionId).orElse(null);
        if (existing != null) {
            if (!existing.isParticipant(requesterId)) {
                throw new IllegalStateException("You are not allowed to access this room.");
            }
            return toRoomResponse(existing);
        }

        TransactionEntity tx = transactionRepository.findById(transactionId)
                .orElseThrow(() -> new IllegalArgumentException("Transaction not found: " + transactionId));

        Long renterId = tx.getRenter().getId();
        Long ownerId = tx.getOwner().getId();
        if (!requesterId.equals(renterId) && !requesterId.equals(ownerId)) {
            throw new IllegalStateException("You are not allowed to create a room for this transaction.");
        }

        UserEntity renter = userRepository.findById(renterId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + renterId));
        UserEntity owner = userRepository.findById(ownerId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + ownerId));

        LocalDateTime now = LocalDateTime.now();
        MessageRoomEntity room = MessageRoomEntity.builder()
                .transaction(tx)
                .renter(renter)
                .owner(owner)
                .createdAt(now)
                .updatedAt(now)
                .build();

        return toRoomResponse(roomRepository.save(room));
    }

    @Transactional(readOnly = true)
    public List<RoomResponse> listRooms(Long userId) {
        return roomRepository.findByRenter_IdOrOwner_IdOrderByUpdatedAtDesc(userId, userId)
                .stream()
                .map(this::toRoomResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<MessageResponse> listMessages(Long roomId, Long requesterId, LocalDateTime before, Integer size) {
        MessageRoomEntity room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        if (!room.isParticipant(requesterId)) {
            throw new IllegalStateException("You are not allowed to access this room.");
        }

        int pageSize = (size == null || size <= 0 || size > 200) ? DEFAULT_PAGE_SIZE : size;
        var pageable = PageRequest.of(0, pageSize);

        List<MessageEntity> rows;
        if (before == null) {
            rows = messageRepository.findByRoom_IdOrderBySentAtDesc(roomId, pageable);
        } else {
            rows = messageRepository.findByRoom_IdAndSentAtBeforeOrderBySentAtDesc(roomId, before, pageable);
        }

        return rows.stream()
                .sorted((a, b) -> a.getSentAt().compareTo(b.getSentAt()))
                .map(this::toMessageResponse)
                .toList();
    }

    @Transactional
    public MessageResponse sendMessage(Long roomId, Long senderId, String content) {
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("Message content is empty.");
        }
        if (content.length() > 2000) {
            throw new IllegalArgumentException("Message content is too long (max 2000).");
        }

        MessageRoomEntity room = roomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("Room not found: " + roomId));
        if (!room.isParticipant(senderId)) {
            throw new IllegalStateException("You are not allowed to send messages to this room.");
        }

        UserEntity sender = userRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + senderId));

        LocalDateTime now = LocalDateTime.now();
        MessageEntity message = MessageEntity.builder()
                .room(room)
                .sender(sender)
                .content(content.trim())
                .sentAt(now)
                .build();

        MessageEntity saved = messageRepository.save(message);

        room.touch();
        roomRepository.save(room);

        return toMessageResponse(saved);
    }

    private RoomResponse toRoomResponse(MessageRoomEntity room) {
        return RoomResponse.builder()
                .roomId(room.getId())
                .transactionId(room.getTransaction().getId())
                .renterId(room.getRenter().getId())
                .ownerId(room.getOwner().getId())
                .updatedAt(room.getUpdatedAt())
                .build();
    }

    private MessageResponse toMessageResponse(MessageEntity message) {
        return MessageResponse.builder()
                .id(message.getId())
                .roomId(message.getRoom().getId())
                .senderId(message.getSender().getId())
                .content(message.getContent())
                .sentAt(message.getSentAt())
                .build();
    }
}
