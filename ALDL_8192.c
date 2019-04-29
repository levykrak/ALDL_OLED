/*
 * ALDL_8192.c
 *
 * Created: 2016-06-02 16:10:44
 *  Author: Piotr Dzidowski
 */ 
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <util/atomic.h>
#include "ALDL_8192.h"

volatile uint8_t RX_complete=1, TxFlag, RX_timeout_ctr;
volatile uint8_t RCV_buffer[ALDL_BODY_SIZE];
const __flash uint8_t send_mssg0[] = {CMD_MSSG0};

static inline void ALDL_Timer_init() {
	TCCR0B = (1 << CS00) | (1 << CS02);	/* Preskaler 1024 */
	TIMSK0 = (1 << TOIE0);				/* Overflow Interrupt Enable */
}

ISR(TIMER0_OVF_vect) {
	if(RX_timeout_ctr) RX_timeout_ctr--;
}

void ALDL_init() {
	/* Ustawienie bitrate USART */
	#include <util/setbaud.h>
	UBRR0H = UBRRH_VALUE;
	UBRR0L = UBRRL_VALUE;
	#if USE_2X
	UCSR0A |= (1 << U2X0);
	#else
	UCSR0A &= ~(1 << U2X0);
	#endif
	/* W³¹czenie nadajnika i odbiornika USART z przerwaniami */
	UCSR0B = (1 << TXEN0) | (1 << RXEN0) | (1 << RXCIE0) | (1 << TXCIE0);
	/* 8 bitów danych */
	UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
	/* Ustaw pin kontroli nadawania jako wyjœcie */
	RX_CTRL_OUT;
	ALDL_Timer_init();
}

ISR(USART_RX_vect) {
	static uint8_t rcv_byte_no = 0;
	RCV_buffer[rcv_byte_no] = UDR0;
	if( ++rcv_byte_no >= ALDL_BODY_SIZE ) 
	{
		rcv_byte_no = 0;
		RX_complete = 1;
	}
}

ISR(USART_TX_vect) {
	static uint8_t tx_byte_no = 0;
	if( tx_byte_no < MSSG0_SIZE )
	{
		/* nadaj kolejny bajt */
		UDR0 = send_mssg0[tx_byte_no];
		TxFlag = 1;
		++tx_byte_no;
	}
	else
	{
		/* Koniec nadawania */
		UCSR0B |= (1 << RXEN0);	/* W³¹cz odbiornik USART */
		tx_byte_no = 0;
		TxFlag = 0;
	}	
}

/* Obliczanie sumy kontrolnej (CRC-1) */
static int ALDL_checksum_OK(volatile uint8_t * buffer) {
	uint8_t i, sum = 0;
	for( i = 0; i < ALDL_BODY_SIZE-1; i++ )
	sum += buffer[i];
	sum = (~sum) + 1;
	if( sum == buffer[ALDL_BODY_SIZE-1] )
	return 1;
	else
	return 0;
}

int ALDL_task() {
	if(RX_complete || !RX_timeout_ctr)	/* Jeœli zakoñczono odbiór ramki lub przekroczono czas */
	{
		ATOMIC_BLOCK(ATOMIC_RESTORESTATE)
		{
			if(!TxFlag)	/* Jeœli nie nadajemy */
			{
				/* Rozpocznij nadawanie */
				UCSR0B &= ~(1 << RXEN0);	/* Wy³¹cz odbiornik USART (nie odbieraj echa) */
				USART_TX_vect();			/* Wywo³anie przerwania nadawania USART */
			}
		}
		RX_complete = 0;
		RX_timeout_ctr = (ALDL_TIMEOUT*(F_CPU/1000))/262144UL;
		if(ALDL_checksum_OK(RCV_buffer))
		{
			/* Jeœli suma kontrolna bufora jest OK, skopiuj bufor odbioru do pamiêci */
			for(uint8_t i=0; i<ALDL_PAYLOAD; i++)
			ALDL.byte[i] = RCV_buffer[i+ALDL_OFFSET];
		}
		else
		return 1;
	}
	return 0;
}