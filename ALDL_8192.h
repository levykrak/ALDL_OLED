/*
 * ALDL_8192.h
 *
 * Created: 2016-06-02 16:10:33
 *  Author: Piotr Dzidowski
 */ 

#ifndef ALDL_8192_H_
#define ALDL_8192_H_

#define RX_CTRL_OUT DDRB  |= (1 << PB0)
#define RX_CTRL_IS_SET (PORTB & (1 << PB0))
#define RX_CTRL_SET PORTB |= (1 << PB0)
#define RX_CTRL_CLR PORTB &= ~(1 << PB0)

#define MASK_0D

#ifdef MASK_0D

#define BAUD 8192

#define ALDL_BODY_SIZE 67
#define ALDL_PAYLOAD 63
#define ALDL_OFFSET 3
#define ALDL_TIMEOUT 2000	/* [ms] */

/* Komenda odczytu danych z ECU */
#define CMD_MSSG0 0xF4, 0x57, 0x01, 0x00, 0xB4
#define MSSG0_SIZE 5

#define CMD_CLR_CODES 0xF4, 0x56, 0x0A, 0xAC 

typedef struct {
	
	uint16_t PROM_ID;				//Offset 0
	
	uint8_t O2_Sensor_Flag		: 1;	//Offset 2
	uint8_t CL_timer_Flag		: 1;
	uint8_t RAM_refresh_Flag	: 1;
	uint8_t Shutdown_Flag		: 1;
	uint8_t Hot_restart_Flag	: 1;
	uint8_t :1;
	uint8_t :1;
	uint8_t MALF_42_Flag		: 1;
	
	uint8_t AC_Flag					: 1;	//Offset 3
	uint8_t Gear_select_Flag		: 1;
	uint8_t RPM_CL_conditions_Flag	: 1;
	uint8_t RPM_CL_Flag				: 1;
	uint8_t Stall_Saver_Flag		: 1;
	uint8_t Power_Steering_Flag		: 1;
	uint8_t Thrttl_Kicker_dsbl_Flag	: 1;
	uint8_t Idle_RPM_High_Flag		: 1;
	
	uint8_t IAC_actual_position;		//Offset 4
	
	uint8_t MALF_21	: 1;		//Offset 5
	uint8_t 		: 1;
	uint8_t 		: 1;
	uint8_t 		: 1;
	uint8_t MALF_16	: 1;
	uint8_t MALF_15	: 1;
	uint8_t MALF_14	: 1;
	uint8_t MALF_13	: 1;
	
	uint8_t			: 1;	//Offset 6
	uint8_t MALF_28	: 1;
	uint8_t 		: 1;
	uint8_t 		: 1;
	uint8_t MALF_25	: 1;
	uint8_t MALF_24	: 1;
	uint8_t MALF_23	: 1;
	uint8_t MALF_22	: 1;
	
	uint8_t	MALF_38	: 1;	//Offset 7
	uint8_t MALF_37	: 1;
	uint8_t MALF_36	: 1;
	uint8_t MALF_35	: 1;
	uint8_t MALF_34	: 1;
	uint8_t MALF_33	: 1;
	uint8_t MALF_32	: 1;
	uint8_t MALF_31	: 1;
	
	uint8_t			: 1;	//Offset 8
	uint8_t MALF_46	: 1;
	uint8_t MALF_45	: 1;
	uint8_t MALF_44	: 1;
	uint8_t MALF_43	: 1;
	uint8_t MALF_42	: 1;
	uint8_t MALF_41	: 1;
	uint8_t MALF_39	: 1;
	
	uint8_t			: 1;		//Offset 9
	uint8_t MALF_55	: 1;
	uint8_t MALF_54	: 1;
	uint8_t MALF_53	: 1;
	uint8_t MALF_52	: 1;
	uint8_t MALF_51	: 1;
	uint8_t			: 1;
	uint8_t			: 1;
	
	uint8_t IAC_desired_position;	//Offset 10
	
	uint8_t Byte11;	//Offset 11
	
	uint8_t Byte12;	//Offset 12
	
	uint8_t Byte13;	//Offset 13
	
	uint8_t Coolant_temp;	//Offset 14
	
	uint8_t Batt_Voltage;	//Offset 15	 //Desired AFR
	
	uint8_t TPS_Voltage;		//Offset 16
	
	uint8_t MAP_value;		//Offset 17
	
	uint8_t O2_sensor;		//Offset 18
		
	uint8_t	PE_delay	: 1;		//Offset 19
	uint8_t VATS_test	: 1;
	uint8_t BLM_addr	: 1;
	uint8_t BLM_delay	: 1;
	uint8_t DE_flag		: 1;
	uint8_t PE_flag		: 1;
	uint8_t	AE_flag		: 1;
	uint8_t	Async_flag	: 1;
	
	uint8_t Byte20;				//Offset 20
	
	uint8_t Byte21;				//Offset 21
	
	uint8_t Byte22;				//Offset 22
	
	uint8_t Byte23;				//Offset 23
	
	uint8_t Byte24;				//Offset 24
	
	uint8_t Byte25;				//Offset 25
	
	uint8_t BARO_pressure;		//Offset 26
	
	uint8_t Byte27;				//Offset 27
	
	uint8_t Byte28;				//Offset 28
	
	uint8_t Byte29;				//Offset 29
	
	uint8_t Vehicle_Speed;		//Offset 30
	
	uint8_t Byte31;				//Offset 31
	
	uint8_t Fuel_Pump_voltage;	//Offset 32
	
	uint8_t TACH;				//Offset 33
	
	uint16_t Loop_Ref_Period;	//Offset 34
	
	uint8_t EGR_PWM;			//Offset 36
	
	uint8_t Byte37;				//Offset 37
	
	uint16_t Engine_running_time;//Offset 38
	
	uint8_t Desired_Idle_RPM;	//Offset 40
	
	uint8_t TPS;				//Offset 41
	
	uint8_t Byte42;				//Offset 42
	
	uint8_t Byte43;				//Offset 43
	
	uint16_t Spark_Advance;		//Offset 44
		
	uint16_t Knock_Counts;		//Offset 46
	
	uint8_t INTEGRATOR;			//Offset 48
	
	uint8_t Governing_TPS;		//Offset 49
	
	uint8_t O2_cross_count;		//Offset 50
	
	uint8_t Byte51;				//Offset 51
	
	uint8_t Byte52;				//Offset 52
	
	uint8_t BLM_Cell;			//Offset 53
	
	uint8_t BLM;				//Offset 54
	
	uint8_t Knock_Retard;		//Offset 55
	
	uint16_t INJ_Base_PW;		//Offset 56
	
	uint8_t EGR_desired;		//Offset 58
	
	uint8_t EGR_actual;			//Offset 59
	
	uint8_t EGR_position;		//Offset 60		//WBO2 AFR
	
	uint8_t CCP_PWM;				//Offset 61
	
	uint8_t MAT_sensor;			//Offset 62
	
}T_ALDL_DATA;

#endif

#ifdef MASK_EE
/* TO DO: stworzyæ maskê dla LT1 ($EE) */
#define BAUD 8192

#define ALDL_BODY_SIZE 67
#define ALDL_PAYLOAD 63
#define ALDL_OFFSET 3
#define ALDL_TIMEOUT 2000	/* [ms] */

/* Komenda odczytu danych z ECU */
#define CMD_MSSG0 0xF4, 0x57, 0x01, 0x00, 0xB4
#define MSSG0_SIZE 5

#define CMD_CLR_CODES 0xF4, 0x56, 0x0A, 0xAC
 
typedef struct {
	
	uint16_t PROM_ID;				//Offset 0
	
	uint8_t O2_Sensor_Flag		: 1;	//Offset 2
	uint8_t CL_timer_Flag		: 1;
	uint8_t RAM_refresh_Flag	: 1;
	uint8_t Shutdown_Flag		: 1;
	uint8_t Hot_restart_Flag	: 1;
	uint8_t :1;
	uint8_t :1;
	uint8_t MALF_42_Flag		: 1;
	
	uint8_t AC_Flag					: 1;	//Offset 3
	uint8_t Gear_select_Flag		: 1;
	uint8_t RPM_CL_conditions_Flag	: 1;
	uint8_t RPM_CL_Flag				: 1;
	uint8_t Stall_Saver_Flag		: 1;
	uint8_t Power_Steering_Flag		: 1;
	uint8_t Thrttl_Kicker_dsbl_Flag	: 1;
	uint8_t Idle_RPM_High_Flag		: 1;
	
	uint8_t IAC_actual_position;		//Offset 4
	
	uint8_t MALF_21	: 1;		//Offset 5
	uint8_t 		: 1;
	uint8_t 		: 1;
	uint8_t 		: 1;
	uint8_t MALF_16	: 1;
	uint8_t MALF_15	: 1;
	uint8_t MALF_14	: 1;
	uint8_t MALF_13	: 1;
	
	uint8_t			: 1;	//Offset 6
	uint8_t MALF_28	: 1;
	uint8_t 		: 1;
	uint8_t 		: 1;
	uint8_t MALF_25	: 1;
	uint8_t MALF_24	: 1;
	uint8_t MALF_23	: 1;
	uint8_t MALF_22	: 1;
	
	uint8_t	MALF_38	: 1;	//Offset 7
	uint8_t MALF_37	: 1;
	uint8_t MALF_36	: 1;
	uint8_t MALF_35	: 1;
	uint8_t MALF_34	: 1;
	uint8_t MALF_33	: 1;
	uint8_t MALF_32	: 1;
	uint8_t MALF_31	: 1;
	
	uint8_t			: 1;	//Offset 8
	uint8_t MALF_46	: 1;
	uint8_t MALF_45	: 1;
	uint8_t MALF_44	: 1;
	uint8_t MALF_43	: 1;
	uint8_t MALF_42	: 1;
	uint8_t MALF_41	: 1;
	uint8_t MALF_39	: 1;
	
	uint8_t			: 1;		//Offset 9
	uint8_t MALF_55	: 1;
	uint8_t MALF_54	: 1;
	uint8_t MALF_53	: 1;
	uint8_t MALF_52	: 1;
	uint8_t MALF_51	: 1;
	uint8_t			: 1;
	uint8_t			: 1;
	
	uint8_t IAC_desired_position;	//Offset 10
	
	uint8_t Byte11;	//Offset 11
	
	uint8_t Byte12;	//Offset 12
	
	uint8_t Byte13;	//Offset 13
	
	uint8_t Coolant_temp;	//Offset 14
	
	uint8_t Batt_Voltage;	//Offset 15	 //Desired AFR
	
	uint8_t TPS_Voltage;		//Offset 16
	
	uint8_t MAP_value;		//Offset 17
	
	uint8_t O2_sensor;		//Offset 18
	
	uint8_t	PE_delay	: 1;		//Offset 19
	uint8_t VATS_test	: 1;
	uint8_t BLM_addr	: 1;
	uint8_t BLM_delay	: 1;
	uint8_t DE_flag		: 1;
	uint8_t PE_flag		: 1;
	uint8_t	AE_flag		: 1;
	uint8_t	Async_flag	: 1;
	
	uint8_t Byte20;				//Offset 20
	
	uint8_t Byte21;				//Offset 21
	
	uint8_t Byte22;				//Offset 22
	
	uint8_t Byte23;				//Offset 23
	
	uint8_t Byte24;				//Offset 24
	
	uint8_t Byte25;				//Offset 25
	
	uint8_t BARO_pressure;		//Offset 26
	
	uint8_t Byte27;				//Offset 27
	
	uint8_t Byte28;				//Offset 28
	
	uint8_t Byte29;				//Offset 29
	
	uint8_t Vehicle_Speed;		//Offset 30
	
	uint8_t Byte31;				//Offset 31
	
	uint8_t Fuel_Pump_voltage;	//Offset 32
	
	uint8_t TACH;				//Offset 33
	
	uint16_t Loop_Ref_Period;	//Offset 34
	
	uint8_t EGR_PWM;			//Offset 36
	
	uint8_t Byte37;				//Offset 37
	
	uint16_t Engine_running_time;//Offset 38
	
	uint8_t Desired_Idle_RPM;	//Offset 40
	
	uint8_t TPS;				//Offset 41
	
	uint8_t Byte42;				//Offset 42
	
	uint8_t Byte43;				//Offset 43
	
	uint16_t Spark_Advance;		//Offset 44
	
	uint16_t Knock_Counts;		//Offset 46
	
	uint8_t INTEGRATOR;			//Offset 48
	
	uint8_t Governing_TPS;		//Offset 49
	
	uint8_t O2_cross_count;		//Offset 50
	
	uint8_t Byte51;				//Offset 51
	
	uint8_t Byte52;				//Offset 52
	
	uint8_t BLM_Cell;			//Offset 53
	
	uint8_t BLM;				//Offset 54
	
	uint8_t Knock_Retard;		//Offset 55
	
	uint16_t INJ_Base_PW;		//Offset 56
	
	uint8_t EGR_desired;		//Offset 58
	
	uint8_t EGR_actual;			//Offset 59
	
	uint8_t EGR_position;		//Offset 60		//WBO2 AFR
	
	uint8_t CCP_PWM;				//Offset 61
	
	uint8_t MAT_sensor;			//Offset 62
	
}T_ALDL_DATA;

#endif

union {
	uint8_t byte[ALDL_PAYLOAD];
	T_ALDL_DATA data;
	} ALDL;

void ALDL_init();

int ALDL_task();

#endif /* ALDL_8192_H_ */