package eos.lendy.payment.service;

import eos.lendy.payment.client.TossPaymentsClient;
import eos.lendy.payment.dto.PaymentConfirmRequest;
import eos.lendy.payment.dto.PaymentConfirmResponse;
import eos.lendy.payment.dto.PaymentPrepareResponse;
import eos.lendy.payment.entity.PaymentEntity;
import eos.lendy.payment.entity.PaymentStatus;
import eos.lendy.payment.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final TossPaymentsClient tossPaymentsClient;

    public PaymentPrepareResponse prepare(Long rentalId) {

        // TODO: 나중에 rental 도메인에서 실제 금액 가져오기
        long rentFee = 10000L;
        long deposit = 5000L;
        long totalAmount = rentFee + deposit;

        String orderId = UUID.randomUUID().toString();

        PaymentEntity payment = PaymentEntity.builder()
                .orderId(orderId)
                .amount(totalAmount)
                .status(PaymentStatus.READY)
                .rentalId(rentalId)
                .build();

        paymentRepository.save(payment);

        return new PaymentPrepareResponse(orderId, totalAmount);
    }

    @Transactional
    public PaymentConfirmResponse confirm(PaymentConfirmRequest req) {

        PaymentEntity payment = paymentRepository.findByOrderId(req.getOrderId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 orderId 입니다."));

        // 조작 방지: 서버에 저장된 금액과 FE가 준 amount가 같아야 함
        if (!payment.getAmount().equals(req.getAmount())) {
            throw new IllegalArgumentException("amount가 일치하지 않습니다.");
        }

        // 중복 승인 방지(이미 승인된 주문이면 그대로 반환)
        if (payment.getStatus() == PaymentStatus.CONFIRMED) {
            return new PaymentConfirmResponse(
                    payment.getOrderId(),
                    payment.getPaymentKey(),
                    payment.getAmount(),
                    payment.getStatus().name()
            );
        }

        // 토스 승인 호출 (성공해야 아래로 내려옴)
        tossPaymentsClient.confirm(req.getPaymentKey(), req.getOrderId(), req.getAmount());

        // 토스 승인 성공 시에만 DB 상태 변경
        payment.confirm(req.getPaymentKey());

        return new PaymentConfirmResponse(
                payment.getOrderId(),
                payment.getPaymentKey(),
                payment.getAmount(),
                payment.getStatus().name()
        );
    }
}
